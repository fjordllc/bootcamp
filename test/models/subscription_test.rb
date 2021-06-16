# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test '#create' do
    subscription = travel_to Time.zone.parse('2000-01-01 00:00:00') do
      Subscription.new.create('cus_12345678')
    end

    assert subscription['id'].present?
  end

  test '#destroy' do
    subscription = Subscription.new.destroy('sub_12345678')
    assert subscription['id'].present?
  end

  test '#all' do
    subscriptions = Subscription.new.all
    assert_equal 'sub_xxxxxxxx', subscriptions.first['id']
  end
end
