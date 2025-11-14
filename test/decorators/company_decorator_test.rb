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
    expected = "http://localhost:3000/users/new?company_id=#{@company1.id}&role=adviser&token=token"
    assert_equal expected, @company1.adviser_sign_up_url
  end

  test '#trainee_sign_up_url' do
    expected = "http://localhost:3000/users/new?company_id=#{@company1.id}&role=trainee&token=token"
    assert_equal expected, @company1.trainee_sign_up_url
  end
end
