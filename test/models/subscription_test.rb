# frozen_string_literal: true

require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "#create" do
    stub_subscription_create!

    subscription = travel_to Time.parse("2000-01-01 00:00:00") do
      Subscription.new.create("cus_12345678")
    end

    assert subscription["id"].present?
  end

  test "#destroy" do
    stub_subscription_destroy!

    subscription = Subscription.new.destroy("sub_12345678")
    assert subscription["id"].present?
  end
end
