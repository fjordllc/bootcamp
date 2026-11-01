# frozen_string_literal: true

require 'test_helper'

class PaidUserRegistrationTest < ActiveSupport::TestCase
  def setup
    @user = users(:kimura)
    @stripe_token = 'stripe-test-token'
    @idempotency_token = 'test-idempotency-token'
  end

  test 'does not call Stripe when user is invalid' do
    @user.stub(:validate, false) do
      Card.stub(:new, -> { flunk 'Card.newが呼び出されました' }) do
        result = PaidUserRegistration.call(
          user: @user,
          stripe_token: @stripe_token,
          idempotency_token: @idempotency_token
        )

        assert result.failure?
        assert_equal :invalid_user, result.reason
      end
    end
  end

  test 'does not save user and adds error when customer is duplicate' do
    card = Object.new
    card.define_singleton_method(:search) { |**| Object.new }

    Card.stub(:new, card) do
      @user.stub(:save, -> { flunk 'ユーザーが保存されました' }) do
        result = PaidUserRegistration.call(
          user: @user,
          stripe_token: @stripe_token,
          idempotency_token: @idempotency_token
        )

        assert result.failure?
        assert_equal :duplicate_customer, result.reason
        assert_includes @user.errors[:base], '同じメールアドレスの顧客が既に登録済みです。'
      end
    end
  end

  test 'does not save user and adds error when card error occurs' do
    card_error = Stripe::CardError.new(
      'カードが拒否されました',
      nil,
      code: 'card_declined'
    )

    card = Object.new
    card.define_singleton_method(:search) { |**| nil }
    card.define_singleton_method(:create) do |_user, _stripe_token, _token|
      raise card_error
    end

    Card.stub(:new, card) do
      @user.stub(:save, -> { flunk 'ユーザーが保存されました' }) do
        result = PaidUserRegistration.call(
          user: @user,
          stripe_token: @stripe_token,
          idempotency_token: @idempotency_token
        )

        assert result.failure?
        assert_equal :card_error, result.reason
        assert_includes(
          @user.errors[:base],
          I18n.translate('stripe.errors.card_declined')
        )
      end
    end
  end
end
