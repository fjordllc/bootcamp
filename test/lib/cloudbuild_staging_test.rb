# frozen_string_literal: true

require 'yaml'
require 'test_helper'

class CloudbuildStagingTest < ActiveSupport::TestCase
  CONFIG = Rails.root.join('.cloudbuild/cloudbuild-staging.yaml')
  BUILD_REGION = 'asia-northeast1'

  test 'uses the regional build location for build API calls' do
    steps = YAML.safe_load_file(CONFIG).fetch('steps')
    cancel_script = steps.find { |step| step['id'] == 'CancelPreviousBuilds' }.fetch('args').last
    write_env_args = steps.find { |step| step['id'] == 'WriteSubstitutionEnv' }.fetch('args')

    assert_includes cancel_script, "--region=#{BUILD_REGION}"
    assert_not_includes cancel_script, '--region=global'
    assert_equal BUILD_REGION, write_env_args.last
  end
end
