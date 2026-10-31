# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require 'yaml'
require 'active_support/core_ext/enumerable'

class CloudbuildReviewCacheTest < Minitest::Test
  ROOT = File.expand_path('../..', __dir__)
  CONFIG = YAML.safe_load_file(File.join(ROOT, '.cloudbuild/cloudbuild-review.yaml'))
  CACHE_IMAGE = 'asia.gcr.io/bootcamp-224405/bootcamp:pr-${_PR_NUMBER}-gems'
  IMAGE_REPOSITORY = 'asia.gcr.io/bootcamp-224405/bootcamp'
  CURRENT_TAGS = %w[pr-10673 pr-10673-gems].map { |tag| "#{IMAGE_REPOSITORY}:#{tag}" }.freeze
  OTHER_TAGS = %w[pr-10674 pr-10674-gems].map { |tag| "#{IMAGE_REPOSITORY}:#{tag}" }.freeze

  # Model the official container/images/{delete,untag}.py semantics: delete
  # resolves a tag to its digest and deletes the image; untag removes one alias.
  FAKE_GCLOUD = <<~'RUBY'
    require 'json'
    File.open(ENV.fetch('GCLOUD_COMMAND_LOG'), 'a') { |log| log.puts(JSON.generate(ARGV)) }
    abort 'Unsupported cloud command' unless ARGV.take(2) == %w[container images]
    operation, image, *flags = ARGV.drop(2)
    abort 'Unsupported operation' unless %w[delete untag].include?(operation)
    allowed_flags = operation == 'delete' ? %w[--quiet --force-delete-tags] : %w[--quiet]
    abort 'Unsupported flags' unless (flags - allowed_flags).empty?
    if image == ENV['ERROR_TAG']
      warn 'ERROR: PERMISSION_DENIED: simulated client failure'
      exit 7
    end
    path = ENV.fetch('REGISTRY_STATE')
    registry = JSON.parse(File.read(path))
    tags = registry.fetch('tags')
    digest = tags[image]
    unless digest
      warn 'ERROR: Image could not be found'
      exit 1
    end
    if operation == 'untag'
      tags.delete(image)
    else
      aliases = tags.select { |_tag, target| target == digest }.keys
      abort 'Additional tags require --force-delete-tags' if aliases != [image] && !flags.include?('--force-delete-tags')
      aliases.each { |tag| tags.delete(tag) }
      registry.fetch('digests').delete(digest)
    end
    File.write(path, JSON.generate(registry))
  RUBY

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

  def test_cleanup_preserves_other_pr_aliases_and_shared_images
    registry = registry_state
    result = run_image_cleanup(registry)

    assert_cleanup_result result, registry
  end

  def test_runtime_and_cache_can_share_one_digest_with_another_pr
    registry = registry_state(shared_digest: true)
    result = run_image_cleanup(registry)

    assert_cleanup_result result, registry
  end

  def test_cleanup_keeps_untagged_images_and_layers
    registry = registry_state
    OTHER_TAGS.each { |tag| registry.fetch('tags').delete(tag) }

    assert_cleanup_result run_image_cleanup(registry), registry
  end

  def test_cleanup_is_idempotent_with_either_or_both_current_tags_missing
    [[], [CURRENT_TAGS.first], [CURRENT_TAGS.last], CURRENT_TAGS].each do |missing_tags|
      registry = registry_state
      missing_tags.each { |tag| registry.fetch('tags').delete(tag) }
      first = run_image_cleanup(registry)
      assert_cleanup_result first, registry
      assert_cleanup_result run_image_cleanup(first.fetch(:registry)), first.fetch(:registry)
    end
  end

  def test_client_failure_warns_accurately_and_attempts_the_other_tag
    CURRENT_TAGS.each do |error_tag|
      registry = registry_state
      result = run_image_cleanup(registry, error_tag: error_tag)

      assert_cleanup_result result, registry, retained_tags: [error_tag]
      assert_includes result.fetch(:stderr), 'PERMISSION_DENIED'
      assert_includes result.fetch(:stderr), "WARNING: Could not remove tag #{error_tag}"
      assert_includes result.fetch(:stderr), 'it may be absent or the registry request may have failed'
      refute_match(/not found|deleted|removed successfully/i, result.fetch(:stdout)) # rubocop:disable Rails/RefuteMethods
    end
  end

  def test_invalid_pr_numbers_are_rejected_before_running_any_cloud_command
    ['', '10673-gems', '10673 10674', '$(gcloud unexpected)', '"; gcloud unexpected; #'].each do |pr_number|
      registry = registry_state
      result = run_image_cleanup(registry, pr_number: pr_number)

      assert_equal 1, result.fetch(:status).exitstatus
      assert_includes result.fetch(:stderr), 'Invalid PR number'
      assert_empty result.fetch(:commands)
      assert_equal registry, result.fetch(:registry)
    end
  end

  private

  def registry_state(shared_digest: false)
    runtime = "sha256:#{'a' * 64}"
    gems = shared_digest ? runtime : "sha256:#{'b' * 64}"
    {
      'tags' => (CURRENT_TAGS + OTHER_TAGS).zip([runtime, gems, runtime, gems]).to_h,
      'digests' => [runtime, gems].uniq.index_with { |digest| ['shared-base-layer', "layer-#{digest}"] }
    }
  end

  def assert_cleanup_result(result, initial, retained_tags: [])
    assert_predicate result.fetch(:status), :success?, "#{result.fetch(:stdout)}\n#{result.fetch(:stderr)}"
    removed_tags = CURRENT_TAGS - retained_tags
    expected_tags = initial.fetch('tags').reject { |tag, _digest| removed_tags.include?(tag) }
    assert_equal expected_tags, result.fetch(:registry).fetch('tags'), 'Other PR aliases must survive cleanup'
    assert_equal initial.fetch('digests'), result.fetch(:registry).fetch('digests'), 'Digests and layers must survive cleanup'
    assert_equal(CURRENT_TAGS, result.fetch(:commands).map { |command| command.fetch(3) })
    result.fetch(:commands).each do |command|
      assert_equal %w[container images untag], command.take(3)
      assert_equal ['--quiet'], command.drop(4)
    end
  end

  def run_image_cleanup(registry, pr_number: '10673', error_tag: '')
    config = YAML.safe_load_file(File.join(ROOT, '.cloudbuild/cloudbuild-review-cleanup.yaml'))
    step = config.fetch('steps').find { |candidate| candidate.fetch('id') == 'DeleteImage' }
    assert_equal ['Kill_SqlProxy'], step.fetch('waitFor')
    assert config.fetch('options').fetch('automapSubstitutions')

    with_fake_registry(registry, pr_number, error_tag) do |env, dir|
      shell = ['/bin/bash', '--noprofile', '--norc']
      probe, errors, probe_status = Open3.capture3(env, *shell, '-c', 'printf "%s\\n" "$PATH"; command -v gcloud', unsetenv_others: true)
      assert_predicate probe_status, :success?, errors
      assert_equal [dir, File.join(dir, 'gcloud')], probe.lines.map(&:chomp), 'Only the fake client may be reachable'
      # One pass models Cloud Build substitutions: escaped dollars become shell
      # variables, while unescaped substitutions are injected before bash parses.
      args = step.fetch('args').map do |arg|
        arg.gsub(/\$\$|\$\{_PR_NUMBER\}|\$_PR_NUMBER/) { |match| match == '$$' ? '$' : pr_number }
      end
      assert_equal 'bash', step.fetch('entrypoint')
      stdout, stderr, status = Open3.capture3(env, *shell, *args, chdir: dir, unsetenv_others: true)
      { stdout: stdout, stderr: stderr, status: status,
        commands: File.readlines(env.fetch('GCLOUD_COMMAND_LOG')).map { |line| JSON.parse(line) },
        registry: JSON.parse(File.read(env.fetch('REGISTRY_STATE'))) }
    end
  end

  def with_fake_registry(registry, pr_number, error_tag)
    Dir.mktmpdir('review-cleanup-test') do |dir|
      gcloud = File.join(dir, 'gcloud')
      File.write(gcloud, "#!#{RbConfig.ruby}\n#{FAKE_GCLOUD}")
      File.chmod(0o755, gcloud)
      log = File.join(dir, 'commands')
      state = File.join(dir, 'registry.json')
      File.write(log, '')
      File.write(state, JSON.generate(registry))
      # No inherited PATH, shell startup files or real cloud executables.
      env = { 'PATH' => dir, 'BASH_ENV' => '/dev/null', 'ENV' => '/dev/null',
              'GCLOUD_COMMAND_LOG' => log, 'REGISTRY_STATE' => state, 'ERROR_TAG' => error_tag, '_PR_NUMBER' => pr_number }
      yield env, dir
    end
  end

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
