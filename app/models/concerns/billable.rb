# frozen_string_literal: true

module Billable
  extend ActiveSupport::Concern

  def customer
    return unless customer_id?

    Customer.new.retrieve(customer_id)
  end

  def card?
    customer_id?
  end

  alias paid? card?

  def card
    customer.sources.data.first
  end

  def subscription?
    subscription_id?
  end

  def subscription
    return unless subscription?

    Subscription.new.retrieve(subscription_id)
  end
end
