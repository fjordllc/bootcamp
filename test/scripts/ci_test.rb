# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require 'json'
require 'rbconfig'

# Standalone Minitest does not provide Rails assert_not.
# rubocop:disable Rails/RefuteMethods
class CiTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)

  def setup
    @tmp = Dir.mktmpdir('bootcamp-ci')
    @repo = File.join(@tmp, 'repo')
    @fake_bin = File.join(@tmp, 'commands')
    FileUtils.mkdir_p(["#{@repo}/bin", "#{@repo}/config", @fake_bin])
    %w[bin/ci bin/cloud-ci config/ci.rb].each do |file|
      FileUtils.cp("#{ROOT}/#{file}", "#{@repo}/#{file}") if File.exist?("#{ROOT}/#{file}")
    end
    File.write("#{@repo}/config/boot.rb", '')
    @log = File.join(@tmp, 'commands.jsonl')
    install_recorders
    @env = { 'PATH' => "#{@fake_bin}:#{ENV.fetch('PATH')}", 'COMMAND_LOG' => @log,
             'RAILS_ENV' => 'development', 'PARALLEL_WORKERS' => nil, 'FAIL_COMMAND' => nil,
             'RUBYOPT' => '-rbundler/setup', 'BUNDLE_GEMFILE' => File.join(ROOT, 'Gemfile') }
    git('init', '--initial-branch=topic/local-ci')
    git('add', '.')
    git('-c', 'user.name=CI Test', '-c', 'user.email=ci@example.test', 'commit', '-m', 'initial')
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def test_plain_ci_runs_all_checks_from_root_without_signoff
    output, status = run_script('ci')
    assert status.success?, output
    commands = calls.map { |call| call.fetch('command').join(' ') }
    %w[rubocop slim-lint traceroute].each { |check| assert commands.any? { |command| command.include?(check) }, commands.inspect }
    assert_includes commands, 'bundle exec rubocop --ignore-parent-exclusion --format progress'
    ['bundle check', 'npm ci', 'npm run lint', 'rails db:prepare', 'rails assets:clean assets:precompile', 'rails test:all'].each do |command|
      assert_includes commands, command
    end
    refute(commands.any? { |command| command.match?(/signoff|setup|replant|rubocop -a|npm install/) })
    assert(calls.all? { |call| call['cwd'] == @repo })
    assert_match(/passed in/, output)
  end

  def test_ci_uses_test_environment_except_traceroute_without_forcing_parallelism
    output, status = run_script('ci')
    assert status.success?, output
    calls.each do |call|
      expected_environment = call['command'].include?('traceroute') ? 'development' : 'test'
      assert_equal expected_environment, call.dig('env', 'RAILS_ENV')
      assert_equal 'Asia/Tokyo', call.dig('env', 'TZ')
    end
    assert(calls.all? { |call| !call['env'].key?('PARALLEL_WORKERS') })
    traceroute = calls.find { |call| call['command'].include?('traceroute') }
    assert_equal '1', traceroute.dig('env', 'FAIL_ON_ERROR')
  end

  def test_each_check_failure_prevents_signoff_and_returns_failure
    ['bundle check', 'npm ci', 'bundle exec rubocop --ignore-parent-exclusion --format progress',
     'bundle exec slim-lint app/views -c config/slim_lint.yml', 'bundle exec rake traceroute',
     'npm run lint', 'rails db:prepare', 'rails assets:clean assets:precompile', 'rails test:all'].each do |command|
      FileUtils.rm_f(@log)
      output, status = run_script('ci', '--signoff', env: { 'FAIL_COMMAND' => command })
      refute status.success?, "#{command}: #{output}"
      refute calls.any? { |call| call['command'] == %w[gh signoff] }, command
      assert calls.any? { |call| call['command'].join(' ') == command }, output
    end
  end

  def test_signoff_is_explicit_and_preserves_parallel_opt_in
    output, status = run_script('ci', '--signoff', env: { 'PARALLEL_WORKERS' => '4' })
    assert status.success?, output
    assert_equal %w[gh signoff], calls.last['command']
    assert(calls.all? { |call| call.dig('env', 'PARALLEL_WORKERS') == '4' })
  end

  def test_signoff_error_propagates
    output, status = run_script('ci', '--signoff', env: { 'FAIL_COMMAND' => 'gh signoff' })
    refute status.success?, output
  end

  def test_invalid_arguments_and_help_do_not_run_commands
    %w[ci cloud-ci].each do |script|
      output, status = run_script(script, '--unknown')
      refute status.success?, output
      assert_empty calls
      output, status = run_script(script, '--help')
      assert status.success?, output
      assert_match(/Usage:/, output)
      assert_empty calls
    end
  end

  def test_signoff_rejects_dirty_checkout_before_checks
    File.write("#{@repo}/untracked", 'change')
    output, status = run_script('ci', '--signoff')
    refute status.success?, output
    assert_empty calls
  end

  def test_cloud_dispatch_uses_current_pushed_branch_from_any_directory
    push_branch
    output, status = run_script('cloud-ci')
    assert status.success?, output
    expected = ['gh', 'workflow', 'run', 'ci.yml', '--repo', "#{@tmp}/remote.git", '--ref', 'topic/local-ci']
    assert_equal([expected], calls.map { |call| call['command'] })
    assert_equal @repo, calls.first['cwd']
  end

  def test_cloud_requires_pushing_branch_missing_from_configured_origin
    configure_origin
    output, status = run_script('cloud-ci')
    refute status.success?, output
    assert_includes output, 'Push topic/local-ci to origin before running cloud CI'
    refute_match(/Check Git configuration and network access/, output)
    assert_empty calls
  end

  def test_cloud_reports_invalid_origin_as_verification_error
    git('remote', 'add', 'origin', File.join(@tmp, 'missing.git'))
    output, status = run_script('cloud-ci')
    refute status.success?, output
    assert_includes output, 'Could not verify the branch on origin. Check Git configuration and network access.'
    refute_match(%r{Push topic/local-ci to origin}, output)
    assert_empty calls
  end

  def test_cloud_rejects_unpushed_dirty_detached_and_remote_mismatch
    output, status = run_script('cloud-ci')
    refute status.success?, output
    assert_empty calls
    push_branch
    File.write("#{@repo}/untracked", 'change')
    output, status = run_script('cloud-ci')
    refute status.success?, output
    assert_empty calls
    FileUtils.rm("#{@repo}/untracked")
    git('checkout', '--detach')
    output, status = run_script('cloud-ci')
    refute status.success?, output
    assert_empty calls
    git('checkout', 'topic/local-ci')
    git('-c', 'user.name=CI Test', '-c', 'user.email=ci@example.test', 'commit', '--allow-empty', '-m', 'unpushed')
    output, status = run_script('cloud-ci')
    refute status.success?, output
    assert_empty calls
  end

  def test_cloud_dispatch_failure_propagates
    push_branch
    output, status = run_script('cloud-ci', env: { 'FAIL_COMMAND' => "gh workflow run ci.yml --repo #{@tmp}/remote.git --ref topic/local-ci" })
    refute status.success?, output
    assert_equal 7, status.exitstatus
  end

  def test_signoff_rejects_checkout_changed_during_ci
    output, status = run_script('ci', '--signoff', env: { 'CHANGE_CHECKOUT' => '1' })
    refute status.success?, output
    assert_match(/checkout changed during CI/, output)
    refute(calls.any? { |call| call['command'] == %w[gh signoff] })
  end

  private

  def install_recorders
    recorder = <<~'SCRIPT'
      #!/usr/bin/env ruby
      require 'json'
      name = File.basename($PROGRAM_NAME)
      File.open(ENV.fetch('COMMAND_LOG'), 'a') do |file|
        file.puts JSON.generate(command: [name, *ARGV], cwd: Dir.pwd,
                                env: ENV.to_h.slice('RAILS_ENV', 'TZ', 'PARALLEL_WORKERS', 'FAIL_ON_ERROR'))
      end
      File.write('changed-during-ci', 'change') if name == 'rails' && ARGV == ['test:all'] && ENV['CHANGE_CHECKOUT'] == '1'
      exit 7 if ENV['FAIL_COMMAND'] == [name, *ARGV].join(' ')
    SCRIPT
    %w[bundle npm gh].each { |name| executable("#{@fake_bin}/#{name}", recorder) }
    executable("#{@repo}/bin/rails", recorder)
  end

  def executable(path, content)
    File.write(path, content)
    FileUtils.chmod(0o755, path)
  end

  def git(*args)
    output, status = Open3.capture2e('git', *args, chdir: @repo)
    raise output unless status.success?

    output.strip
  end

  def configure_origin
    remote = File.join(@tmp, 'remote.git')
    output, status = Open3.capture2e('git', 'init', '--bare', remote)
    raise output unless status.success?

    git('remote', 'add', 'origin', remote)
  end

  def push_branch
    configure_origin
    git('push', '-u', 'origin', 'HEAD')
  end

  def run_script(script, *args, env: {})
    Open3.capture2e(@env.merge(env), RbConfig.ruby, "#{@repo}/bin/#{script}", *args, chdir: @tmp)
  end

  def calls
    File.exist?(@log) ? File.readlines(@log).map { |line| JSON.parse(line) } : []
  end
end

# rubocop:enable Rails/RefuteMethods
