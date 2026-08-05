# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test '#retrieve' do
    VCR.use_cassette 'subscription/retrieve' do
      subscription = Subscription.new.retrieve('sub_12345678')
      assert_equal 'sub_12345678', subscription['id']
    end
  end

  test '#create' do
    travel_to Time.zone.parse('2023-01-01 00:00:00') do
      VCR.use_cassette 'subscription/create', record: :once, match_requests_on: %i[method uri] do
        subscription = Subscription.new.create('cus_12345678')
        assert_equal 'sub_12345678', subscription['id']
      end
    end
  end

  test '#destroy' do
    VCR.use_cassette 'subscription/update' do
      subscription = Subscription.new.destroy('sub_12345678')
      assert_equal 'sub_12345678', subscription['id']
    end
  end

  test '#destroy succeeds if the subscription is canceled concurrently' do
    statuses = %w[active canceled].map { |status| Struct.new(:status).new(status) }
    error = Stripe::InvalidRequestError.new(
      'A canceled subscription can only update its cancellation_details and metadata.',
      'subscription'
    )

    Stripe::Subscription.stub(:retrieve, ->(*) { statuses.shift }) do
      Stripe::Subscription.stub(:update, ->(*) { raise error }) do
        assert Subscription.new.destroy('sub_12345678')
      end
    end
  end

  test '#all' do
    VCR.use_cassette 'subscription/list' do
      subscriptions = Subscription.new.all
      assert_equal 'sub_12345678', subscriptions.first['id']
    end
  end
end
