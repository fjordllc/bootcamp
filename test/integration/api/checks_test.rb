# frozen_string_literal: true

require 'test_helper'

class API::ChecksTest < ActionDispatch::IntegrationTest
  fixtures :checks, :products, :reports

  setup do
    @check1 = checks(:report4_check_komagata)
    @check2 = checks(:report1_check_machida)
    @check3 = checks(:report3_check_machida)
    @check4 = checks(:report5_check_machida)
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    @student_token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:kimura).id,
      scopes: 'read write mentor'
    )
    @mentor_read_token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read mentor'
    )
    @mentor_write_token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read write mentor'
    )
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
    assert_response :unprocessable_entity

    # adviser login
    token = create_token('advijirou', 'testtest')
    post api_checks_path(format: :json),
         params: { checkable_type: @check3.checkable_type, checkable_id: @check3.checkable_id },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity

    # mentor login
    token = create_token('mentormentaro', 'testtest')
    post api_checks_path(format: :json),
         params: { checkable_type: @check4.checkable_type, checkable_id: @check4.checkable_id },
         headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unprocessable_entity
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
    assert_response :ok
    assert_equal @check2.id, response.parsed_body['id']

    # adviser login
    token = create_token('advijirou', 'testtest')
    delete api_check_path(@check3.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal @check3.id, response.parsed_body['id']

    # mentor login
    token = create_token('mentormentaro', 'testtest')
    delete api_check_path(@check4.id, format: :json),
           headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal @check4.id, response.parsed_body['id']
  end

  test 'POST /api/checks.json with write scope but without mentor scope returns forbidden' do
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read write'
    )

    post api_checks_path(format: :json),
         params: { checkable_type: @check4.checkable_type, checkable_id: @check4.checkable_id },
         headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'mentor can check report with write scope' do
    report = unchecked_report

    assert_difference('Check.count') do
      post api_report_check_path(report, format: :json),
           headers: { Authorization: "Bearer #{@mentor_write_token.token}" }
      assert_response :created
    end

    check = Check.find(response.parsed_body['id'])
    assert_equal 'Report', response.parsed_body['checkable_type']
    assert_equal report.id, response.parsed_body['checkable_id']
    assert_equal users(:mentormentaro).id, response.parsed_body.dig('user', 'id')
    assert_equal check.id, response.parsed_body['id']
  end

  test 'mentor can uncheck report with write scope' do
    report = unchecked_report
    check = Check.create!(checkable: report, user: users(:mentormentaro))

    assert_difference('Check.count', -1) do
      delete api_report_check_path(report, format: :json),
             headers: { Authorization: "Bearer #{@mentor_write_token.token}" }
      assert_response :ok
    end

    assert_equal check.id, response.parsed_body['id']
    assert_equal 'Report', response.parsed_body['checkable_type']
    assert_equal report.id, response.parsed_body['checkable_id']
  end

  test 'mentor can check product with write scope' do
    product = unchecked_product

    assert_difference('Check.count') do
      post api_product_check_path(product, format: :json),
           headers: { Authorization: "Bearer #{@mentor_write_token.token}" }
      assert_response :created
    end

    assert_equal 'Product', response.parsed_body['checkable_type']
    assert_equal product.id, response.parsed_body['checkable_id']
    assert_equal users(:mentormentaro).id, response.parsed_body.dig('user', 'id')
  end

  test 'mentor can uncheck product with write scope' do
    product = unchecked_product
    check = Check.create!(checkable: product, user: users(:mentormentaro))

    assert_difference('Check.count', -1) do
      delete api_product_check_path(product, format: :json),
             headers: { Authorization: "Bearer #{@mentor_write_token.token}" }
      assert_response :ok
    end

    assert_equal check.id, response.parsed_body['id']
    assert_equal 'Product', response.parsed_body['checkable_type']
    assert_equal product.id, response.parsed_body['checkable_id']
  end

  test 'student can not check report' do
    post api_report_check_path(unchecked_report, format: :json),
         headers: { Authorization: "Bearer #{@student_token.token}" }

    assert_response :forbidden
    assert_equal '権限がありません。', response.parsed_body['message']
  end

  test 'mentor can not check report with read scope' do
    post api_report_check_path(unchecked_report, format: :json),
         headers: { Authorization: "Bearer #{@mentor_read_token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'mentor can not check report with write scope but without mentor scope' do
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read write'
    )

    post api_report_check_path(unchecked_report, format: :json),
         headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'returns not found when checking missing report' do
    post api_report_check_path(0, format: :json),
         headers: { Authorization: "Bearer #{@mentor_write_token.token}" }

    assert_response :not_found
    assert_equal '日報が見つかりません。', response.parsed_body['message']
  end

  test 'returns validation error when report is already checked' do
    report = unchecked_report
    Check.create!(checkable: report, user: users(:komagata))

    assert_no_difference('Check.count') do
      post api_report_check_path(report, format: :json),
           headers: { Authorization: "Bearer #{@mentor_write_token.token}" }
    end

    assert_response :unprocessable_entity
    assert_equal 'この日報は確認済です。', response.parsed_body['message']
  end

  private

  def unchecked_report
    Report.left_outer_joins(:checks).where(checks: { id: nil }).order(:id).first
  end

  def unchecked_product
    Product.left_outer_joins(:checks).where(checks: { id: nil }).order(:id).first
  end
end
