# frozen_string_literal: true

require 'test_helper'

class Admin::InvitationUrlControllerTest < ActionDispatch::IntegrationTest
  test 'admin generates an invitation bound to all selections' do
    sign_in :komagata
    get admin_invitation_url_index_path(format: :json), params: invitation_attributes

    assert_response :success
    query = Rack::Utils.parse_query(URI.parse(response.parsed_body.fetch('url')).query)
    assert_equal invitation_attributes.stringify_keys, query.except('token')
    assert_equal invitation_attributes.stringify_keys, RegistrationInvitation.verify(query.fetch('token'))
  end

  test 'HTML supplies an authorized signing endpoint without a token template' do
    sign_in :komagata
    get admin_invitation_url_index_path

    assert_response :success
    assert_select '[data-invitation-url-endpoint=?]', admin_invitation_url_index_path(format: :json)
    assert_select '[data-invitation-url-template]', count: 0
  end

  test 'anonymous visitors cannot generate invitations' do
    get admin_invitation_url_index_path(format: :json), params: invitation_attributes

    assert_response :redirect
  end

  %i[kimura advijirou].each do |user|
    test "#{user} cannot use the admin signing endpoint" do
      sign_in user
      get admin_invitation_url_index_path(format: :json), params: invitation_attributes

      assert_response :redirect
    end
  end

  { role: 'admin', company_id: '999999999', course_id: '999999999' }.each do |key, value|
    test "rejects invalid #{key}" do
      sign_in :komagata
      get admin_invitation_url_index_path(format: :json), params: invitation_attributes.merge(key => value)

      assert_response :unprocessable_entity
      assert_not response.parsed_body.key?('url')
    end
  end

  test 'rejects missing or malformed selections' do
    sign_in :komagata
    [{}, invitation_attributes.merge(company_id: "#{companies(:company1).id}invalid"),
     invitation_attributes.merge(role: ['mentor'])].each do |attributes|
      get admin_invitation_url_index_path(format: :json), params: attributes

      assert_response :unprocessable_entity
      assert_not response.parsed_body.key?('url')
    end
  end

  private

  def invitation_attributes
    { role: 'trainee_invoice_payment', company_id: companies(:company1).id.to_s, course_id: courses(:course1).id.to_s }
  end
end
