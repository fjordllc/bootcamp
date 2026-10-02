# frozen_string_literal: true

require 'yaml'
require 'test_helper'

class CloudbuildProductionTest < ActiveSupport::TestCase
  test 'declares dependencies before the steps that wait for them' do
    prior_ids = []
    YAML.safe_load_file(Rails.root.join('.cloudbuild/cloudbuild.yaml')).fetch('steps').each do |step|
      step.fetch('waitFor', []).each do |dependency|
        next if dependency == '-'

        assert_includes prior_ids, dependency, "#{step.fetch('id')} waits for #{dependency} before it is declared"
      end
      prior_ids << step.fetch('id')
    end
  end

  test 'runs schema migrations before deployment and data migrations after deployment with the SQL proxy available' do
    steps = YAML.safe_load_file(Rails.root.join('.cloudbuild/cloudbuild.yaml')).fetch('steps').index_by { |step| step.fetch('id') }
    schema = steps.fetch('DB_Migrate')
    deploy = steps.fetch('Deploy')
    data = steps.fetch('Data_Migrate')

    assert_includes schema.fetch('args').last, 'bin/rails db:migrate'
    assert_not_includes schema.fetch('args').last, 'db:migrate:with_data'
    assert_equal ['DB_Migrate'], deploy.fetch('waitFor')
    assert_equal ['Deploy'], data.fetch('waitFor')
    assert_includes data.fetch('args').last, 'bin/rails db:migrate:with_data'
    assert_equal schema.fetch('name'), data.fetch('name')
    assert_equal schema.fetch('volumes'), data.fetch('volumes')
    assert data.fetch('automapSubstitutions')
    assert_includes data.fetch('args').last, 'source .cloudbuild/substitutions.env'
    assert_includes data.fetch('args').last, '.cloudbuild/cloud-build-env exports'
    assert_equal ['Data_Migrate'], steps.fetch('Kill_SqlProxy').fetch('waitFor')
  end
end
