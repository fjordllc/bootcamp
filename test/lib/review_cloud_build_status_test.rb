# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'yaml'

# Minitest::TestでRailsなしに実行する。
# rubocop:disable Rails/RefuteMethods

class ReviewCloudBuildStatusTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)
  COMMAND = File.join(ROOT, '.cloudbuild/review-cloud-build-status')
  BUILD_ID = '01234567-89ab-cdef-0123-456789abcdef'
  FAILURES = %w[FAILURE CANCELLED TIMEOUT INTERNAL_ERROR EXPIRED].freeze
  QUERY = '--format=json(id,status,steps[].id,steps[].status,steps[].exitCode)'

  FAKE_GCLOUD = <<~'PYTHON'
    #!/usr/bin/python3
    import json, os, sys
    with open(os.environ['CALLS'], 'a') as log:
        log.write(json.dumps(sys.argv[1:]) + '\n')
    diagnostic = sys.argv[-1].startswith('--format=json(')
    if os.environ['READ_ERROR'] == '1' or (diagnostic and os.environ['DIAGNOSTIC_ERROR'] == '1'):
        print('SECRET credentials in raw stderr', file=sys.stderr)
        sys.exit(7)
    print(open(os.environ['BUILD_JSON_FILE']).read() if diagnostic else os.environ['BUILD_STATUS'])
  PYTHON

  HANGING_DIAGNOSTIC_GCLOUD = <<~'PYTHON'
    #!/usr/bin/python3
    import os, sys, time
    if sys.argv[-1] == '--format=value(status)':
        print('FAILURE')
    else:
        with open(os.environ['CHILD_PID'], 'w') as output:
            output.write(str(os.getpid()))
        print('SECRET diagnostic stdout', flush=True)
        print('SECRET diagnostic stderr', file=sys.stderr, flush=True)
        time.sleep(300)
  PYTHON

  HANGING_DIAGNOSTIC_HARNESS = <<~'PYTHON'
    import json, os, signal, subprocess, sys
    child = subprocess.Popen(
        ['/usr/bin/python3', sys.argv[1], sys.argv[2]],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True,
    )
    timed_out = False
    try:
        stdout, stderr = child.communicate(timeout=20)
    except subprocess.TimeoutExpired:
        timed_out = True
        os.killpg(child.pid, signal.SIGKILL)
        stdout, stderr = child.communicate()
    with open(os.environ['CHILD_PID']) as source:
        diagnostic_pid = int(source.read())
    try:
        os.kill(diagnostic_pid, 0)
    except ProcessLookupError:
        child_gone = True
    else:
        child_gone = False
    print(json.dumps(dict(timed_out=timed_out, code=child.returncode,
                          stdout=stdout.decode(), stderr=stderr.decode(), child_gone=child_gone)))
  PYTHON

  def test_only_explicit_success_passes
    stdout, stderr, status, calls = run_helper('SUCCESS')

    assert_equal 0, status.exitstatus, stderr
    assert_includes stdout, 'Build status: SUCCESS'
    assert_equal [describe('--format=value(status)')], calls
  end

  def test_queued_working_and_pending_are_not_success
    %w[PENDING QUEUED WORKING].each do |build_status|
      stdout, _stderr, status, calls = run_helper(build_status)

      assert_equal 3, status.exitstatus, stdout
      assert_includes stdout, "Build status: #{build_status}"
      assert_equal 1, calls.size
    end
  end

  def test_each_terminal_failure_reports_only_safe_metadata_and_fixed_console_link
    FAILURES.each do |build_status|
      build = { id: BUILD_ID, status: build_status, substitutions: { _DB_PASS: 'SECRET' }, logUrl: 'https://evil/SECRET',
                steps: [{ id: 'CreateDB', status: build_status, exitCode: 17, args: ['SECRET'], env: ['SECRET'] },
                        { id: 'Build', status: 'SUCCESS' }] }
      stdout, stderr, status, calls = run_helper(build_status, build: build)

      assert_equal 1, status.exitstatus
      assert_empty stderr
      assert_includes stdout, "Build ID: #{BUILD_ID}"
      assert_includes stdout, "https://console.cloud.google.com/cloud-build/builds;region=asia-northeast1/#{BUILD_ID}?project=bootcamp-224405"
      assert_includes stdout, "Step ID: CreateDB status: #{build_status} exitCode: 17"
      refute_includes stdout, 'SECRET'
      refute_includes stdout, 'Step ID: Build'
      assert_equal [describe('--format=value(status)'), describe(QUERY)], calls
    end
  end

  def test_api_read_failure_is_visible_without_raw_stderr_or_false_pending
    stdout, stderr, status, calls = run_helper('SUCCESS', read_error: true)

    assert_equal 2, status.exitstatus
    assert_includes stderr, 'status unavailable: gcloud read failed'
    refute_includes stdout + stderr, 'SECRET'
    refute_includes stdout, 'Build status:'
    assert_equal 1, calls.size
  end

  def test_invalid_status_never_passes_or_echoes_untrusted_content
    ['', 'STATUS_UNKNOWN', 'FUTURE_STATUS', 'SUCC', "SUCCESS\nSECRET", "SUCCESS\e[31m", 'S' * 1000].each do |build_status|
      stdout, stderr, status, = run_helper(build_status)

      assert_equal 2, status.exitstatus
      assert_includes stderr, 'invalid build status'
      refute_includes stdout + stderr, 'SECRET'
      refute_includes stdout, 'Build status:'
    end
  end

  def test_failed_build_stays_failed_when_diagnostics_cannot_be_read
    stdout, stderr, status, = run_helper('FAILURE', diagnostic_error: true)

    assert_equal 1, status.exitstatus
    assert_includes stdout, 'Build status: FAILURE'
    assert_includes stderr, 'diagnostics unavailable'
    refute_includes stdout + stderr, 'SECRET'
  end

  def test_hanging_diagnostic_is_killed_and_reaped_and_preserves_build_failure
    Dir.mktmpdir('review-hanging-diagnostic') do |dir|
      stub = File.join(dir, 'gcloud')
      File.write(stub, HANGING_DIAGNOSTIC_GCLOUD)
      File.chmod(0o755, stub)
      env = { 'PATH' => dir, 'CHILD_PID' => File.join(dir, 'child.pid') }
      output, error, status = Open3.capture3(env, '/usr/bin/python3', '-c', HANGING_DIAGNOSTIC_HARNESS, COMMAND, BUILD_ID, unsetenv_others: true)

      assert status.success?, error
      result = JSON.parse(output)
      refute result.fetch('timed_out'), 'Helper blocked for 20 seconds after known FAILURE'
      assert_equal 1, result.fetch('code')
      assert result.fetch('child_gone'), 'Diagnostic child must be killed and reaped before helper returns'
      assert_includes result.fetch('stdout'), 'Build status: FAILURE'
      assert_equal "Build diagnostics unavailable; inspect the build console with authorized access\n", result.fetch('stderr')
      refute_includes result.fetch('stdout') + result.fetch('stderr'), 'SECRET'
    end
  end

  def test_malformed_or_untrusted_diagnostics_are_not_dumped
    ['{"steps":', [], { id: 'SECRET', status: 'FAILURE', steps: [] },
     { id: BUILD_ID, status: 'FAILURE', steps: 'SECRET' },
     { id: BUILD_ID, status: 'FAILURE', steps: Array.new(1001, {}) },
     { id: BUILD_ID, status: 'FAILURE', steps: [{ id: "bad\n::error::SECRET", status: 'FAILURE', exitCode: 'SECRET' }] },
     { id: BUILD_ID, status: 'FAILURE', steps: [{ id: 'a' * 1000, status: 'FAILURE', exitCode: 1 }] },
     'S' * 262_145].each do |build|
      stdout, stderr, status, = run_helper('FAILURE', build: build)

      assert_equal 1, status.exitstatus
      assert_includes stderr, 'diagnostics unavailable'
      refute_includes stdout + stderr, 'SECRET'
      refute_includes stdout, '::error::'
      assert_operator (stdout + stderr).bytesize, :<, 1000
    end
  end

  def test_missing_failed_step_details_remain_explicit
    build = { id: BUILD_ID, status: 'FAILURE', steps: [{ status: 'FAILURE' }, { id: 'NotStarted' }] }
    stdout, stderr, status, = run_helper('FAILURE', build: build)

    assert_equal 1, status.exitstatus
    assert_empty stderr
    assert_includes stdout, 'Step ID: [unnamed] status: FAILURE exitCode: unavailable'
    refute_includes stdout, 'Step ID: NotStarted'
  end

  def test_step_fields_are_validated_independently_before_any_step_output
    [{ id: 'CreateDB', status: "FAILURE\nSECRET" },
     { id: 'CreateDB', status: 'FAILURE', exitCode: 'SECRET' },
     { id: 'CreateDB', status: 'FAILURE', exitCode: true },
     { id: 'CreateDB', status: 'FAILURE', exitCode: 2**31 },
     { id: ['SECRET'], status: 'FAILURE' }].each do |step|
      build = { id: BUILD_ID, status: 'FAILURE', steps: [{ id: 'Valid', status: 'FAILURE' }, step] }
      stdout, stderr, status, = run_helper('FAILURE', build: build)

      assert_equal 1, status.exitstatus
      assert_includes stderr, 'diagnostics unavailable'
      refute_includes stdout + stderr, 'SECRET'
      refute_includes stdout, 'Step ID:'
    end
  end

  def test_workflow_propagates_terminal_and_unexpected_helper_failures_without_sleep
    [1, 2, 23].each do |code|
      stdout, stderr, status, sleeps = run_workflow_poll(code, 0)

      assert_equal code, status.exitstatus, stderr
      assert_empty sleeps
      refute_includes stdout, 'Build succeeded!'
    end
  end

  def test_workflow_sleeps_only_for_pending_and_accepts_explicit_success
    stdout, stderr, status, sleeps = run_workflow_poll(3, 0)

    assert_equal 0, status.exitstatus, stderr
    assert_includes stdout, 'Build succeeded!'
    assert_equal ["30\n"], sleeps
  end

  def test_workflow_exhausted_poll_budget_fails
    stdout, stderr, status, sleeps = run_workflow_poll(3, 3)

    assert_equal 1, status.exitstatus, stderr
    assert_includes stdout, 'Timeout waiting for build'
    refute_includes stdout, 'Build succeeded!'
    assert_equal Array.new(2, "30\n"), sleeps
  end

  def test_invalid_build_id_is_not_used_as_an_argument_or_printed
    stdout, stderr, status, calls = run_helper('SUCCESS', build_id: "--SECRET\n::error::")

    assert_equal 2, status.exitstatus
    assert_empty calls
    refute_includes stdout + stderr, 'SECRET'
  end

  def test_workflow_uses_helper_and_preserves_poll_budget
    script = workflow_script

    assert_includes script, 'python3 .cloudbuild/review-cloud-build-status "$BUILD_ID"'
    assert_includes script, 'seq 1 120'
    assert_includes script, 'sleep 30'
    assert_includes script, '[ "$POLL_STATUS" -ne 3 ]'
    refute_match(/gcloud builds describe.*?\|\| true/m, script)
  end

  private

  def workflow_script
    workflow = YAML.safe_load_file(File.join(ROOT, '.github/workflows/review-app.yml'))
    workflow.fetch('jobs').fetch('deploy').fetch('steps').find { |step| step['name'] == 'Deploy Review App via Cloud Build' }.fetch('run')
  end

  def run_workflow_poll(first_code, second_code)
    Dir.mktmpdir('review-workflow-poll') do |dir|
      scripts = { 'seq' => "printf '1\\n2\\n'",
                  'sleep' => 'echo "$1" >> "$SLEEPS"',
                  'python3' => 'if [ -f "$CALLED" ]; then exit "$SECOND_CODE"; else : > "$CALLED"; exit "$FIRST_CODE"; fi' }
      scripts.each do |name, script|
        File.write(File.join(dir, name), "#!/bin/sh\n#{script}\n")
        File.chmod(0o755, File.join(dir, name))
      end
      env = { 'PATH' => dir, 'FIRST_CODE' => first_code.to_s, 'SECOND_CODE' => second_code.to_s,
              'CALLED' => File.join(dir, 'called'), 'SLEEPS' => File.join(dir, 'sleeps'), 'BUILD_ID' => BUILD_ID }
      poll = workflow_script[workflow_script.index('for i in $(seq 1 120)')..]
      stdout, stderr, status = Open3.capture3(env, '/bin/bash', '--noprofile', '--norc', '-e', '-c', poll, unsetenv_others: true)
      sleeps = File.exist?(env.fetch('SLEEPS')) ? File.readlines(env.fetch('SLEEPS')) : []
      [stdout, stderr, status, sleeps]
    end
  end

  def describe(format)
    ['builds', 'describe', BUILD_ID, '--project=bootcamp-224405', '--region=asia-northeast1', format]
  end

  def run_helper(build_status, build: {}, read_error: false, diagnostic_error: false, build_id: BUILD_ID)
    Dir.mktmpdir('review-build-status') do |dir|
      stub = File.join(dir, 'gcloud')
      File.write(stub, FAKE_GCLOUD)
      File.chmod(0o755, stub)
      log = File.join(dir, 'calls')
      env = { 'PATH' => dir, 'CALLS' => log, 'BUILD_STATUS' => build_status,
              'BUILD_JSON' => build.is_a?(String) ? build : JSON.generate(build),
              'READ_ERROR' => read_error ? '1' : '0', 'DIAGNOSTIC_ERROR' => diagnostic_error ? '1' : '0' }
      # 大きなfixtureも環境変数のOS上限に依存しないようファイルで渡す。
      fixture = File.join(dir, 'build.json')
      File.write(fixture, env.delete('BUILD_JSON'))
      env['BUILD_JSON_FILE'] = fixture
      stdout, stderr, status = Open3.capture3(env, '/usr/bin/python3', COMMAND, build_id, unsetenv_others: true)
      calls = File.exist?(log) ? File.readlines(log).map { |line| JSON.parse(line) } : []
      [stdout, stderr, status, calls]
    end
  end
end

# rubocop:enable Rails/RefuteMethods
