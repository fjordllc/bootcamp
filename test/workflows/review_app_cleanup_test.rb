# frozen_string_literal: true

require 'test_helper'
require 'yaml'

class ReviewAppCleanupTest < ActiveSupport::TestCase
  WORKFLOW = Rails.root.join('.github/workflows/review-app-cleanup.yml')

  test 'waits for Cloud Build without streaming logs' do
    cleanup_step = YAML.load_file(WORKFLOW).dig('jobs', 'cleanup', 'steps').find do |step|
      step['name'] == 'Cleanup Review App via Cloud Build'
    end
    command = cleanup_step.fetch('run')

    assert_includes command, '--suppress-logs'
    assert_not_includes command, '--async'
  end
end
