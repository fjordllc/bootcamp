# frozen_string_literal: true

module Subscription
  def self.create(customer_id)
    Stripe::Subscription.create(
      customer: customer_id,
      items: [{ plan: Plan.standard_plan.id }]
    )
  end
end
