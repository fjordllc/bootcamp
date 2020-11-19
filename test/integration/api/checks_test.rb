# frozen_string_literal: true

require "test_helper"

class API::ChecksTest < ActionDispatch::IntegrationTest
  fixtures :checks, :reports

  setup do
    @check_1 = checks(:report4_check_komagata)
    @check_2 = checks(:report1_check_machida)
    @check_3 = checks(:report3_check_machida)
    @check_4 = checks(:report5_check_machida)
  end

  test "GET /api/checks.json" do
    get api_checks_path(format: :json),
      params: { checkable_type: @check_1.checkable_type, checkable_id: @check_1.checkable_id }
    assert_response :unauthorized

    # student login
    token = create_token("kimura", "testtest")
    get api_checks_path(format: :json),
      params: { checkable_type: @check_1.checkable_type, checkable_id: @check_1.checkable_id },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :ok
  end

  test "POST /api/checks.json" do
    post api_checks_path(format: :json),
      params: { checkable_type: @check_1.checkable_type, checkable_id: @check_1.checkable_id }
    assert_response :unauthorized

    # student login
    token = create_token("kimura", "testtest")
    post api_checks_path(format: :json),
      params: { checkable_type: @check_1.checkable_type, checkable_id: @check_1.checkable_id },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized

    # admin login
    token = create_token("komagata", "testtest")
    post api_checks_path(format: :json),
      params: { checkable_type: @check_2.checkable_type, checkable_id: @check_2.checkable_id },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :created

    # adviser login
    token = create_token("advijirou", "testtest")
    post api_checks_path(format: :json),
      params: { checkable_type: @check_3.checkable_type, checkable_id: @check_3.checkable_id },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :created

    # mentor login
    token = create_token("yamada", "testtest")
    post api_checks_path(format: :json),
      params: { checkable_type: @check_4.checkable_type, checkable_id: @check_4.checkable_id },
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :created
  end

  test "DELETE /api/checks/1234.json" do
    delete api_check_path(@check_1.id, format: :json)
    assert_response :unauthorized

    # student login
    token = create_token("kimura", "testtest")
    delete api_check_path(@check_1.id, format: :json),
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :unauthorized

    # admin login
    token = create_token("komagata", "testtest")
    delete api_check_path(@check_2.id, format: :json),
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :no_content

    # adviser login
    token = create_token("advijirou", "testtest")
    delete api_check_path(@check_3.id, format: :json),
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :no_content

    # mentor login
    token = create_token("yamada", "testtest")
    delete api_check_path(@check_4.id, format: :json),
      headers: { "Authorization" => "Bearer #{token}" }
    assert_response :no_content
  end
end
