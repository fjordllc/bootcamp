# frozen_string_literal: true

module Subscription
  def self.create(customer_id)
    Stripe::Subscription.create(
      customer: customer_id,
      trial_end: 3.days.since.to_i,
      items: [{ plan: Plan.standard_plan.id }],
    )
  end
end
