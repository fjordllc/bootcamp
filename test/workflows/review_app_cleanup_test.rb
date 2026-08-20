# frozen_string_literal: true

require 'test_helper'

class ReviewAppCleanupTest < ActiveSupport::TestCase
  WORKFLOW = Rails.root.join('.github/workflows/review-app-cleanup.yml')

  test 'waits for Cloud Build without streaming logs' do
    workflow = WORKFLOW.read

    assert_includes workflow, '--suppress-logs'
    assert_not_includes workflow, '--async'
  end
end
