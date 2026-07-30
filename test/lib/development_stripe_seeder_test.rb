# frozen_string_literal: true

require 'test_helper'

class DevelopmentStripeSeederTest < ActiveSupport::TestCase
  test 'rejects non-development environments before querying users' do
    user_query = ->(*) { raise 'User query reached' }

    error = User.stub(:where, user_query) do
      assert_raises(RuntimeError) do
        DevelopmentStripeSeeder.new(api_key: 'sk_test_example').call
      end
    end

    assert_equal 'This seeder is only available in development.', error.message
  end

  test 'rejects a live mode API key' do
    error = Rails.stub(:env, ActiveSupport::EnvironmentInquirer.new('development')) do
      assert_raises(RuntimeError) do
        DevelopmentStripeSeeder.new(api_key: 'sk_live_example').call
      end
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
    user.update_columns(customer_id: nil, subscription_id: 'sub_old') # rubocop:disable Rails/SkipsModelValidations
    old_subscription_id = user.subscription_id
    customer = Struct.new(:id).new('cus_test')
    stripe_subscription = Struct.new(:id).new('sub_test')
    destroyed_subscription_ids = []
    test_case = self
    customer_gateway = Object.new
    customer_gateway.define_singleton_method(:retrieve) { |_id| test_case.flunk 'Customer retrieval should be skipped' }
    card = Object.new
    card.define_singleton_method(:create) { |_user, _token| customer }
    subscription = Object.new
    subscription.define_singleton_method(:create) { |*, **| stripe_subscription }
    subscription.define_singleton_method(:destroy) { |id| destroyed_subscription_ids << id }

    DevelopmentStripeSeeder.new(customer_gateway:, card:, subscription:).seed(user)

    assert_equal [old_subscription_id], destroyed_subscription_ids
    assert_equal 'cus_test', user.reload.customer_id
    assert_equal 'sub_test', user.subscription_id
  end

  test 'recreates a customer when its payment source was deleted' do
    user = users(:hatsuno)
    old_customer_id = user.customer_id
    old_subscription_id = user.subscription_id
    customer_without_card = Struct.new(:id, :default_source).new('cus_old', nil)
    new_customer = Struct.new(:id).new('cus_new')
    stripe_subscription = Struct.new(:id).new('sub_new')
    retrieved_customer_ids = []
    destroyed_subscription_ids = []
    customer_gateway = Object.new
    customer_gateway.define_singleton_method(:retrieve) do |id|
      retrieved_customer_ids << id
      customer_without_card
    end
    card = Object.new
    card.define_singleton_method(:create) { |_user, _token| new_customer }
    subscription = Object.new
    subscription.define_singleton_method(:create) { |*, **| stripe_subscription }
    subscription.define_singleton_method(:destroy) { |id| destroyed_subscription_ids << id }

    DevelopmentStripeSeeder.new(customer_gateway:, card:, subscription:).seed(user)

    assert_equal [old_customer_id], retrieved_customer_ids
    assert_equal [old_subscription_id], destroyed_subscription_ids
    assert_equal 'cus_new', user.reload.customer_id
    assert_equal 'sub_new', user.subscription_id
  end

  test 'reuses an existing customer and subscription' do
    user = users(:hatsuno)
    existing_customer_id = user.customer_id
    existing_subscription_id = user.subscription_id
    customer = Struct.new(:id, :default_source).new(existing_customer_id, 'card_test')
    stripe_subscription = Struct.new(:id).new(existing_subscription_id)
    retrieved_customer_ids = []
    retrieved_subscription_ids = []
    test_case = self
    customer_gateway = Object.new
    customer_gateway.define_singleton_method(:retrieve) do |id|
      retrieved_customer_ids << id
      customer
    end
    card = Object.new
    card.define_singleton_method(:create) { test_case.flunk 'Customer should be reused' }
    subscription = Object.new
    subscription.define_singleton_method(:retrieve) do |id|
      retrieved_subscription_ids << id
      stripe_subscription
    end
    subscription.define_singleton_method(:create) { test_case.flunk 'Subscription should be reused' }
    subscription.define_singleton_method(:destroy) { test_case.flunk 'Active subscription should not be destroyed' }

    DevelopmentStripeSeeder.new(customer_gateway:, card:, subscription:).seed(user)

    assert_equal [existing_customer_id], retrieved_customer_ids
    assert_equal [existing_subscription_id], retrieved_subscription_ids
  end
end
