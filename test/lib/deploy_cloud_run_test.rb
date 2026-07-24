# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'
require 'test_helper'

class DeployCloudRunTest < ActiveSupport::TestCase
  SCRIPT = Rails.root.join('.cloudbuild/deploy-cloud-run').to_s

  test 'deploys with clear-secrets without creating an intermediate service update revision' do
    Dir.mktmpdir do |dir|
      gcloud_log = File.join(dir, 'gcloud.log')
      stub_gcloud(dir, gcloud_log)

      stdout, stderr, status = Open3.capture3(deploy_env(dir), SCRIPT, 'production')
      assert_predicate status, :success?, stderr
      assert_empty stdout

      commands = File.read(gcloud_log)
      assert_includes commands, 'run deploy bootcamp'
      assert_includes commands, '--clear-secrets'
      assert_includes commands, '--env-vars-file'
      assert_not_includes commands, 'services update'
      assert_not_includes commands, '--remove-secrets'
    end
  end

  test 'fails before deploy when required production environment variables are missing' do
    Dir.mktmpdir do |dir|
      gcloud_log = File.join(dir, 'gcloud.log')
      stub_gcloud(dir, gcloud_log)

      env = deploy_env(dir).except('_POSTMARK_API_TOKEN')
      _stdout, stderr, status = Open3.capture3(env, SCRIPT, 'production')

      assert_not_predicate status, :success?
      assert_includes stderr, 'POSTMARK_API_TOKEN'
      assert_not File.exist?(gcloud_log), 'gcloud should not be called'
    end
  end

  test 'uses postmark token from secret env when substitution file contains an empty placeholder' do
    Dir.mktmpdir do |dir|
      gcloud_log = File.join(dir, 'gcloud.log')
      stub_gcloud(dir, gcloud_log)
      substitutions_env = File.join(dir, 'substitutions.env')
      File.write(
        substitutions_env,
        "export _POSTMARK_API_TOKEN=''\n" \
        "export POSTMARK_API_TOKEN=''\n"
      )

      env = deploy_env(dir).merge(
        'SUBSTITUTION_ENV_FILE' => substitutions_env,
        'POSTMARK_API_TOKEN_FROM_SECRET' => 'postmark-token-from-secret'
      )
      _stdout, stderr, status = Open3.capture3(env, SCRIPT, 'production')

      assert_predicate status, :success?, stderr
      assert File.exist?(gcloud_log), 'gcloud should be called'
    end
  end

  test 'keeps a staging instance running with CPU for Solid Queue' do
    Dir.mktmpdir do |dir|
      gcloud_log = File.join(dir, 'gcloud.log')
      stub_gcloud(dir, gcloud_log)

      _stdout, stderr, status = Open3.capture3(deploy_env(dir), SCRIPT, 'staging')
      assert_predicate status, :success?, stderr

      commands = File.read(gcloud_log)
      assert_includes commands, '--min-instances=1'
      assert_includes commands, '--no-cpu-throttling'
    end
  end

  private

  def stub_gcloud(dir, gcloud_log)
    File.write(
      File.join(dir, 'gcloud'),
      <<~BASH
        #!/usr/bin/env bash
        printf '%q ' "$@" >> "#{gcloud_log}"
        printf '\\n' >> "#{gcloud_log}"
      BASH
    )
    FileUtils.chmod('+x', File.join(dir, 'gcloud'))
  end

  def deploy_env(dir)
    {
      'PATH' => "#{dir}:#{ENV.fetch('PATH')}",
      'PROJECT_ID' => 'bootcamp-224405',
      'REPO_NAME' => 'bootcamp',
      'COMMIT_SHA' => 'abc123',
      'BUILD_ID' => 'build123',
      '_APP_HOST_NAME' => 'bootcamp.example.com',
      '_CLOUD_SQL_HOST' => 'project:region:instance',
      '_DB_NAME' => 'bootcamp_production',
      '_DB_USER' => 'production',
      '_GCS_BUCKET' => 'bootcamp-bucket',
      '_LABELS' => 'env=production',
      '_MEMORY' => '4G',
      '_SERVICE_NAME' => 'bootcamp',
      '_TRIGGER_ID' => 'trigger123',
      '_RAILS_MASTER_KEY' => 'master-key',
      '_POSTMARK_API_TOKEN' => 'postmark-token',
      '_DB_PASS' => 'db-pass'
    }
  end
end
