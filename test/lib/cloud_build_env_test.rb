# frozen_string_literal: true

require 'json'
require 'open3'
require 'tempfile'
require 'test_helper'

class CloudBuildEnvTest < ActiveSupport::TestCase
  COMMAND = Rails.root.join('.cloudbuild/cloud-build-env').to_s

  test 'outputs cloud run environment variables as json' do
    env_vars = run_json(
      'cloud-run-json',
      '_' => 'ignored',
      '_APP_HOST_NAME' => 'bootcamp-pr-10119.example.com',
      '_CLOUD_SQL_HOST' => 'project:region:instance',
      '_DB_PASS' => 'p,a,s,s',
      '_GOOGLE_CREDENTIALS' => '{"client_email":"test@example.com","private_key":"a,b,c"}',
      '_MEMORY' => '2G',
      '_SERVICE_NAME' => 'bootcamp-pr-10119'
    )

    assert_equal 'production', env_vars['RAILS_ENV']
    assert_equal 'bootcamp-pr-10119.example.com', env_vars['APP_HOST_NAME']
    assert_equal 'p,a,s,s', env_vars['DB_PASS']
    assert_equal '{"client_email":"test@example.com","private_key":"a,b,c"}', env_vars['GOOGLE_CREDENTIALS']
    assert_equal '/cloudsql/project:region:instance', env_vars['DB_HOST']
    assert_nil env_vars['MEMORY']
    assert_nil env_vars['SERVICE_NAME']
    assert_nil env_vars['CLOUD_SQL_HOST']
    assert_nil env_vars['']
  end

  test 'outputs sourceable exports for app commands' do
    exports = run_command(
      'exports',
      '_APP_HOST_NAME' => 'bootcamp.example.com',
      '_CLOUD_SQL_HOST' => 'project:region:instance',
      '_DB_PASS' => 'p a,s'
    )

    assert_includes exports, "export RAILS_ENV=production\n"
    assert_includes exports, "export DISABLE_DATABASE_ENVIRONMENT_CHECK=1\n"
    assert_includes exports, "export APP_HOST_NAME=bootcamp.example.com\n"
    assert_includes exports, "export DB_PASS='p a,s'\n"
    assert_includes exports, "export DB_HOST=/cloudsql/project:region:instance\n"
  end

  test 'outputs comma separated env vars for commands that still use set-env-vars' do
    env_vars = run_command(
      'cloud-run-env-vars',
      '_APP_HOST_NAME' => 'bootcamp.example.com',
      '_CLOUD_SQL_HOST' => 'project:region:instance',
      '_ENVS' => 'EXTRA=1,FEATURE_FLAG=true',
      '_SERVICE_NAME' => 'bootcamp'
    )

    assert_includes env_vars, 'APP_HOST_NAME=bootcamp.example.com'
    assert_includes env_vars, 'DB_HOST=/cloudsql/project:region:instance'
    assert_includes env_vars, 'EXTRA=1'
    assert_includes env_vars, 'FEATURE_FLAG=true'
    assert_not_includes env_vars, 'SERVICE_NAME=bootcamp'
  end

  test 'writes sourceable exports from cloud build json' do
    build_json = Tempfile.create('build.json')
    output = Tempfile.create('substitutions.env')
    build_json_path = build_json.path
    output_path = output.path

    build_json.write(
      {
        projectId: 'bootcamp-224405',
        id: 'build-id',
        substitutions: {
          'COMMIT_SHA' => 'abc123',
          'REPO_NAME' => 'bootcamp',
          '_' => 'ignored',
          '_APP_HOST_NAME' => 'bootcamp-pr.example.com',
          '_DB_PASS' => 'p a,s',
          '_invalid_name' => 'ignored'
        }
      }.to_json
    )
    build_json.close

    assert system(COMMAND, 'write', output_path, build_json_path)
    exports = output.read

    assert_includes exports, "export PROJECT_ID=bootcamp-224405\n"
    assert_includes exports, "export BUILD_ID=build-id\n"
    assert_includes exports, "export COMMIT_SHA=abc123\n"
    assert_includes exports, "export REPO_NAME=bootcamp\n"
    assert_includes exports, "export _APP_HOST_NAME=bootcamp-pr.example.com\n"
    assert_includes exports, "export APP_HOST_NAME=bootcamp-pr.example.com\n"
    assert_includes exports, "export _DB_PASS='p a,s'\n"
    assert_includes exports, "export DB_PASS='p a,s'\n"
    assert_not_includes exports, 'export ='
    assert_not_includes exports, '_invalid_name'
  ensure
    FileUtils.rm_f(build_json_path)
    FileUtils.rm_f(output_path)
  end

  private

  def run_json(command, env)
    JSON.parse(run_command(command, env))
  end

  def run_command(command, env)
    stdout, stderr, status = Open3.capture3(env, COMMAND, command)
    assert_predicate status, :success?, stderr
    stdout
  end
end
