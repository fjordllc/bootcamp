# frozen_string_literal: true

require 'test_helper'

class UserRegistrationPreparationTest < ActiveSupport::TestCase
  test 'applies invitation attributes to user' do
    registration_invitation = {
      role: 'trainee_invoice_payment',
      company_id: 1,
      course_id: 2
    }

    user = UserRegistrationPreparation.new(
      user_params: {},
      registration_invitation:,
      credit_card_payment: false
    ).call

    assert_equal 1, user.company_id
    assert_equal 2, user.course_id
    assert_equal 'trainee_invoice_payment', user.role
  end
end
