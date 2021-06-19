# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test '#create' do
    subscription = travel_to Time.zone.parse('2023-01-01 00:00:00') do
      VCR.use_cassette 'subscription/create' do
        Subscription.new.create('cus_12345678')
      end
    end
    assert subscription['id'].present?
  end

  test '#destroy' do
    VCR.use_cassette 'subscription/update' do
      subscription = Subscription.new.destroy('sub_12345678')
      assert subscription['id'].present?
    end
  end

  test '#all' do
    VCR.use_cassette 'subscription/list' do
      subscriptions = Subscription.new.all
      assert_equal 'sub_12345678', subscriptions.first['id']
    end
  end
end
