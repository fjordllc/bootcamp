# frozen_string_literal: true

require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require 'yaml'
require 'active_support/core_ext/enumerable'

class CloudbuildReviewCacheTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)
  CONFIG = YAML.safe_load_file(File.join(ROOT, '.cloudbuild/cloudbuild-review.yaml'))
  CACHE_IMAGE = 'asia.gcr.io/bootcamp-224405/bootcamp:pr-${_PR_NUMBER}-gems'

  def test_cache_is_imported_before_dependency_and_application_builds
    steps = CONFIG.fetch('steps').index_by { |step| step.fetch('id') }
    assert_includes steps.keys, 'BuildGems'
    assert_equal ['Fetch'], steps.fetch('BuildGems').fetch('waitFor')
    assert_equal ['BuildGems'], steps.fetch('Build').fetch('waitFor')
    assert_equal ['Build'], steps.fetch('Push').fetch('waitFor')

    %w[BuildGems Build].each do |id|
      step = steps.fetch(id)
      assert_equal 'gcr.io/cloud-builders/docker', step.fetch('name')
      assert_equal 'build', step.fetch('args').first
      assert_includes option_values(step, '--cache-from'), CACHE_IMAGE
      assert_includes option_values(step, '--build-arg'), 'GRPC_BUILD_PROCS=4'
      assert_includes option_values(step, '--build-arg'), 'BUILDKIT_INLINE_CACHE=1'
    end
    assert_equal ['gems'], option_values(steps.fetch('BuildGems'), '--target')
    assert_includes option_values(steps.fetch('BuildGems'), '-t'), CACHE_IMAGE
    assert_includes CONFIG.fetch('images'), CACHE_IMAGE
  end

  def test_all_dependencies_are_declared_before_their_consumers
    prior_ids = []
    CONFIG.fetch('steps').each do |step|
      step.fetch('waitFor', []).each do |dependency|
        next if dependency == '-'

        assert_includes prior_ids, dependency
      end
      prior_ids << step.fetch('id')
    end
  end

  def test_dependency_target_ends_before_application_or_environment_files_are_copied
    dockerfile = File.read(File.join(ROOT, 'Dockerfile'))
    assert_match(/^FROM ruby:\S+ as gems$/i, dockerfile)
    assert_match(/^FROM gems as builder$/i, dockerfile)
    dependencies, application = dockerfile.split(/^FROM gems as builder$/i, 2)

    # These are the only context inputs to the dependency target: source-only
    # changes cannot invalidate it, while either gem manifest can.
    assert_equal ['COPY Gemfile Gemfile.lock ./'], dependencies.lines.grep(/^\s*(?:COPY|ADD)\s/i).map(&:strip)
    assert_match(/^ARG GRPC_BUILD_PROCS=2$/, dependencies)
    assert_match(/^RUN GRPC_RUBY_BUILD_PROCS="\$\{GRPC_BUILD_PROCS\}" bundle install -j4$/, dependencies)
    assert_equal ['ENV RAILS_ENV production'], dependencies.lines.grep(/^ENV /).map(&:strip)
    assert_match(%r{^COPY \. \./$}, application)
    assert_match(/^RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile$/, application)
    assert_match(%r{^COPY --from=builder /usr/local/bundle /usr/local/bundle$}, application)
  end

  def test_missing_cache_allows_a_cold_build_and_fetches_only_the_pr_cache
    fetch = CONFIG.fetch('steps').find { |step| step.fetch('id') == 'Fetch' }
    stdout, stderr, status, commands = run_step(fetch, 'PULL_STATUS' => '1')

    assert_predicate status, :success?, "#{stdout}\n#{stderr}"
    assert_equal ["pull #{CACHE_IMAGE}"], commands
  end

  def test_build_and_push_failures_are_not_suppressed
    steps = CONFIG.fetch('steps').index_by { |step| step.fetch('id') }
    assert_includes steps.keys, 'BuildGems'
    %w[BuildGems Build Push].each do |id|
      step = steps.fetch(id)
      refute step.fetch('allowFailure', false) # rubocop:disable Rails/RefuteMethods
      assert_empty step.fetch('allowExitCodes', [])
      _stdout, stderr, status, commands = run_step(step, 'BUILD_STATUS' => '42', 'PUSH_STATUS' => '43')

      assert_equal(id == 'Push' ? 43 : 42, status.exitstatus, stderr)
      assert_equal 1, commands.size
    end
  end

  private

  def option_values(step, option)
    step.fetch('args').each_cons(2).filter_map { |key, value| value if key == option }
  end

  # Execute the actual configured commands, replacing only the Docker client.
  # This verifies shell fallback/error propagation without a daemon or registry.
  def run_step(step, overrides)
    Dir.mktmpdir('review-cache-test') do |dir|
      docker = File.join(dir, 'docker')
      File.write(docker, <<~'SH')
        #!/bin/sh
        printf '%s\n' "$*" >> "$DOCKER_COMMAND_LOG"
        case "$1" in
          pull) exit "${PULL_STATUS:-0}" ;;
          build) exit "${BUILD_STATUS:-0}" ;;
          push) exit "${PUSH_STATUS:-0}" ;;
          *) exit 99 ;;
        esac
      SH
      File.chmod(0o755, docker)
      log = File.join(dir, 'commands')
      env = { 'PATH' => "#{dir}:#{ENV.fetch('PATH')}", 'DOCKER_COMMAND_LOG' => log }.merge(overrides)
      # Apply the PR substitution as Cloud Build does before executing a step.
      args = step.fetch('args').map { |arg| arg.gsub('${_PR_NUMBER}', '10673') }
      command = step['entrypoint'] ? [step.fetch('entrypoint'), *args] : [docker, *args]
      stdout, stderr, status = Open3.capture3(env, *command, chdir: ROOT)
      commands = File.readlines(log, chomp: true).map { |line| line.gsub('10673', '${_PR_NUMBER}') }
      [stdout, stderr, status, commands]
    end
  end
end
