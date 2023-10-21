# frozen_string_literal: true

require 'test_helper'

class QuizResultsControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    get quiz_results_create_url
    assert_response :success
  end
end
