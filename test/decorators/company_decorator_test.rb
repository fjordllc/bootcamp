# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class CompanyDecoratorTest < ActiveDecoratorTestCase
  setup do
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    ActiveDecorator::ViewContext.push controller.view_context
    @company1 = decorate(companies(:company1))
  end

  test '#adviser_sign_up_url' do
    assert_invitation @company1.adviser_sign_up_url, 'adviser'
  end

  test '#trainee_sign_up_url' do
    assert_invitation @company1.trainee_sign_up_url, 'trainee_select_a_payment_method'
  end

  private

  def assert_invitation(url, role)
    uri = URI.parse(url)
    query = Rack::Utils.parse_query(uri.query)
    assert_equal 'http://test.host/users/new', "#{uri.scheme}://#{uri.host}#{uri.path}"
    assert_equal @company1.id.to_s, query.fetch('company_id')
    assert_equal({ 'role' => role, 'company_id' => @company1.id.to_s }, RegistrationInvitation.verify(query.fetch('token')))
  end
end
