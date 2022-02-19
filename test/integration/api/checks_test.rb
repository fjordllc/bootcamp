# frozen_string_literal: true

require 'test_helper'

class API::ChecksTest < ActionDispatch::IntegrationTest
  fixtures :checks, :reports

  setup do
    @check1 = checks(:report4_check_komagata)
    @check2 = checks(:report1_check_machida)
    @check3 = checks(:report3_check_machida)
    @check4 = checks(:report5_check_machida)
  end

  test 'GET /api/checks.json' do
    get api_checks_path(format: :json),
        params: { checkable_type: @check1.checkable_type, checkable_id: @check1.checkable_id }
    assert_response :unauthorized

    # student login
    token = create_token('kimura', 'testtest')
    get api_checks_path(format: :json),
        params: { checkable_type: @check1.checkable_type, checkable_id: @check1.checkable_id },
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/checks.json' do
    post api_checks_path(format: :json),
         params: { checkable_type: @check1.checkable_type, checkable_id: @check1.checkable_id }
    assert_response :unauthorized

    # student login
    token = create_token('kimura', 'testtest')
    post api_checks_path(format: :json),
         params: { checkable_type: @check1.checkable_type, checkable_id: @check1.checkable_id },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    # admin login
    token = create_token('komagata', 'testtest')
    post api_checks_path(format: :json),
         params: { checkable_type: @check2.checkable_type, checkable_id: @check2.checkable_id },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created

    # adviser login
    token = create_token('advijirou', 'testtest')
    post api_checks_path(format: :json),
         params: { checkable_type: @check3.checkable_type, checkable_id: @check3.checkable_id },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created

    # mentor login
    token = create_token('mentormentaro', 'testtest')
    post api_checks_path(format: :json),
         params: { checkable_type: @check4.checkable_type, checkable_id: @check4.checkable_id },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :created
  end

  test 'DELETE /api/checks/1234.json' do
    delete api_check_path(@check1.id, format: :json)
    assert_response :unauthorized

    # student login
    token = create_token('kimura', 'testtest')
    delete api_check_path(@check1.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    # admin login
    token = create_token('komagata', 'testtest')
    delete api_check_path(@check2.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content

    # adviser login
    token = create_token('advijirou', 'testtest')
    delete api_check_path(@check3.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content

    # mentor login
    token = create_token('mentormentaro', 'testtest')
    delete api_check_path(@check4.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :no_content
  end
end
