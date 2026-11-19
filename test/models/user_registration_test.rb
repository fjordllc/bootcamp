# frozen_string_literal: true

require 'test_helper'

class UserRegistrationTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      role: 'trainee_invoice_payment',
      email: 'new-user@example.com',
      login_name: 'new-user',
      password: 'password123',
      invoice_payment: true,
      company: companies(:company2),
      course: courses(:course1),
      name: 'テストユーザー',
      name_kana: 'テストユーザー',
      description: 'テスト用の自己紹介です。',
      job: 'office_worker',
      os: 'mac',
      organization: 'テスト企業'
    )
    @user.assign_role
  end

  test 'passes the newly created user URL to the registration notifier' do
    actual_url = nil
    persisted_when_notified = false
    result = nil

    UserRegistrationNotifier.stub(:new, lambda {
      Object.new.tap do |notifier|
        notifier.define_singleton_method(:call) do |user, url|
          actual_url = url
          persisted_when_notified = user.persisted?
        end
      end
    }) do
      result = UserRegistration.new(
        user_params: @user.attributes.merge(password: 'password123'),
        registration_invitation: nil,
        payment_params: {
          credit_card_payment: nil,
          stripe_token: nil,
          idempotency_token: nil
        },
        affiliate_rd_code: nil
      ).call
    end

    user = result.user

    assert user.persisted?
    assert persisted_when_notified

    expected_url = Rails.application.routes.url_helpers.user_url(user)
    assert_equal expected_url, actual_url
  end

  test 'applies invitation attributes to user' do
    registration_invitation = RegistrationInvitation.new(
      'role' => 'trainee_invoice_payment',
      'company_id' => companies(:company2).id.to_s,
      'course_id' => courses(:course1).id.to_s
    )

    result = UserRegistration.new(
      user_params: @user.attributes.merge(password: 'password123'),
      registration_invitation: registration_invitation,
      payment_params: {
        credit_card_payment: false,
        stripe_token: nil,
        idempotency_token: nil
      },
      affiliate_rd_code: nil
    ).call

    user = result.user

    assert_equal companies(:company2).id, user.company_id
    assert_equal courses(:course1).id, user.course_id
    assert_equal 'trainee_invoice_payment', user.role
  end
end
