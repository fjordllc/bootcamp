# frozen_string_literal: true

require 'json'
require 'open3'
require 'tmpdir'
require 'yaml'
require 'fileutils'
require 'minitest/autorun'
require 'active_support/core_ext/enumerable'

class CloudSdkPythonTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)
  COMMAND = File.join(ROOT, '.cloudbuild/with-cloud-sdk-python')

  def test_makes_sdk_python_available_to_commands_and_nested_env_shebangs_without_changing_argv
    with_sdk_python do |env, dir|
      _stdout, _stderr, status = Open3.capture3(env, '/bin/bash', '--noprofile', '--norc', '-c', 'command -v python3', unsetenv_others: true)
      refute status.success?, 'The initial PATH must not contain python3' # rubocop:disable Rails/RefuteMethods

      nested = File.join(dir, 'nested-python')
      File.write(nested, "#!/usr/bin/env python3\nimport json, sys\nprint(json.dumps(sys.argv[1:]))\n")
      File.chmod(0o755, nested)
      args = ['argument with spaces', '', 'literal $value; *']
      stdout, stderr, status = Open3.capture3(
        env, '/bin/bash', '--noprofile', '--norc', COMMAND, 'python3', '-c',
        'import subprocess, sys; subprocess.run(sys.argv[1:], check=True)', nested, *args, unsetenv_others: true
      )

      assert_predicate status, :success?, stderr
      assert_equal args, JSON.parse(stdout)
    end
  end

  def test_preserves_gcloud_failure_without_launching_command
    with_sdk_python do |env, _dir|
      stdout, _stderr, status = Open3.capture3(
        env.merge('GCLOUD_STATUS' => '37'), '/bin/bash', '--noprofile', '--norc', COMMAND, '/bin/bash', '-c', 'printf launched', unsetenv_others: true
      )

      assert_equal 37, status.exitstatus
      assert_empty stdout
    end
  end

  def test_preserves_wrapped_command_exit_status
    with_sdk_python do |env, _dir|
      _stdout, stderr, status = Open3.capture3(env, '/bin/bash', '--noprofile', '--norc', COMMAND, '/bin/bash', '-c', 'exit 23', unsetenv_others: true)

      assert_equal 23, status.exitstatus, stderr
    end
  end

  def test_wraps_environment_generation_and_deployment_in_all_cloud_sdk_configurations
    %w[cloudbuild-staging.yaml cloudbuild.yaml cloudbuild-review.yaml].each do |filename|
      steps = YAML.safe_load_file(File.join(ROOT, '.cloudbuild', filename)).fetch('steps').index_by { |step| step.fetch('id') }
      { 'WriteSubstitutionEnv' => 'python3', 'Deploy' => 'bash' }.each do |id, command|
        step = steps.fetch(id)
        assert_equal 'bash', step.fetch('entrypoint'), "#{filename}: #{id}"
        assert_equal ['.cloudbuild/with-cloud-sdk-python', command], step.fetch('args').take(2), "#{filename}: #{id}"
      end
    end
  end

  def test_wraps_link_checker_job_updates_with_cloud_sdk_python
    {
      'cloudbuild.yaml' => 'UpdateLinkCheckerJob',
      'cloudbuild-link-checker-job.yaml' => 'CreateOrUpdateJob'
    }.each do |filename, id|
      steps = YAML.safe_load_file(File.join(ROOT, '.cloudbuild', filename)).fetch('steps').index_by { |step| step.fetch('id') }
      step = steps.fetch(id)

      assert_equal 'bash', step.fetch('entrypoint'), "#{filename}: #{id}"
      assert_equal ['.cloudbuild/with-cloud-sdk-python', 'bash', '-c'], step.fetch('args').take(3), "#{filename}: #{id}"
    end
  end

  private

  def with_sdk_python
    Dir.mktmpdir('cloud-sdk-python-test') do |dir|
      bin = File.join(dir, 'bin')
      sdk_bin = File.join(dir, 'SDK with spaces', 'bin')
      FileUtils.mkdir_p([bin, sdk_bin])
      python, status = Open3.capture2('python3', '-c', 'import sys; print(sys.executable)')
      assert_predicate status, :success?
      File.symlink(python.strip, File.join(sdk_bin, 'python3'))
      File.symlink('/usr/bin/dirname', File.join(bin, 'dirname'))
      gcloud = File.join(bin, 'gcloud')
      File.write(gcloud, <<~'SH')
        #!/bin/bash
        [[ "$#" == 2 && "$1" == info && "$2" == "--format=value(basic.python_location)" ]] || exit 99
        [[ "${GCLOUD_STATUS:-0}" == 0 ]] || exit "$GCLOUD_STATUS"
        printf '%s\n' "$SDK_PYTHON"
      SH
      File.chmod(0o755, gcloud)
      env = { 'PATH' => bin, 'BASH_ENV' => '/dev/null', 'ENV' => '/dev/null', 'SDK_PYTHON' => File.join(sdk_bin, 'python3') }
      yield env, dir
    end
  end
end
