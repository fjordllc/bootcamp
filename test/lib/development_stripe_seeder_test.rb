# frozen_string_literal: true

require 'test_helper'

class DevelopmentStripeSeederTest < ActiveSupport::TestCase
  test 'rejects a live mode API key' do
    error = assert_raises(RuntimeError) do
      DevelopmentStripeSeeder.new(api_key: 'sk_live_example').call
    end

    assert_equal 'Stripe test mode API key is required.', error.message
  end

  test 'creates Stripe resources for a hibernated seed user' do
    assert defined?(DevelopmentStripeSeeder), 'DevelopmentStripeSeeder is not defined'

    user = users(:kyuukai)
    customer = Struct.new(:id).new('cus_test')
    stripe_subscription = Struct.new(:id).new('sub_test')
    customer_gateway = Object.new
    customer_gateway.define_singleton_method(:retrieve) do |_id|
      raise Stripe::InvalidRequestError.new('No such customer', 'id')
    end
    card = Object.new
    card.define_singleton_method(:create) { |_user, _token| customer }
    subscription = Object.new
    subscription.define_singleton_method(:create) { |*, **| stripe_subscription }
    subscription.define_singleton_method(:destroy) { |id| @destroyed_id = id }
    subscription.define_singleton_method(:destroyed_id) { @destroyed_id }

    DevelopmentStripeSeeder.new(customer_gateway:, card:, subscription:).seed(user)

    assert_equal 'cus_test', user.reload.customer_id
    assert_equal 'sub_test', user.subscription_id
    assert_equal 'sub_test', subscription.destroyed_id
  end

  test 'creates Stripe resources when a seed user has no customer ID' do
    user = users(:kimura)
    customer = Struct.new(:id).new('cus_test')
    stripe_subscription = Struct.new(:id).new('sub_test')
    test_case = self
    customer_gateway = Object.new
    customer_gateway.define_singleton_method(:retrieve) { |_id| test_case.flunk 'Customer retrieval should be skipped' }
    card = Object.new
    card.define_singleton_method(:create) { |_user, _token| customer }
    subscription = Object.new
    subscription.define_singleton_method(:create) { |*, **| stripe_subscription }
    subscription.define_singleton_method(:destroy) { test_case.flunk 'Active subscription should not be destroyed' }

    DevelopmentStripeSeeder.new(customer_gateway:, card:, subscription:).seed(user)

    assert_equal 'cus_test', user.reload.customer_id
    assert_equal 'sub_test', user.subscription_id
  end
end
