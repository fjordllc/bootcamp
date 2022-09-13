# frozen_string_literal: true

require 'test_helper'

class API::CoursesTest < ActionDispatch::IntegrationTest
  test 'GET /api/courses.json' do
    get api_courses_path(format: :json)
    assert_response :unauthorized

    token = create_token('hatsuno', 'testtest')
    get api_courses_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
