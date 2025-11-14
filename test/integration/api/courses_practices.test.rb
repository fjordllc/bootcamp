# frozen_string_literal: true

require 'test_helper'

class Api::CoursesPracticesTest < ActionDispatch::IntegrationTest
  test 'GET /api/courses/1234/practices.json' do
    @courses = courses(:course1)
    get api_course_practices_path(@courses.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_course_practices_path(@courses.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
