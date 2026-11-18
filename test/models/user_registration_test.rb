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

    UserRegistrationNotifier.stub(:new, lambda {
      Object.new.tap do |notifier|
        notifier.define_singleton_method(:call) do |user, url|
          actual_url = url
          persisted_when_notified = user.persisted?
        end
      end
    }) do
      UserRegistration.new(@user, nil, nil, nil).call
    end

    expected_url = Rails.application.routes.url_helpers.user_url(@user)

    assert @user.persisted?
    assert persisted_when_notified
    assert_equal expected_url, actual_url
  end
end
