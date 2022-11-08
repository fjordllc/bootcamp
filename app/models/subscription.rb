# frozen_string_literal: true

class Subscription
  STATUS_CLASS_MAP = {
    'trialing': 'is-primary',
    'active': 'is-success',
    'canceled': 'is-danger',
    'past_due': 'is-warning'
  }.freeze

  def retrieve(id)
    Stripe::Subscription.retrieve(id)
  end

  def create(customer_id, idempotency_key = SecureRandom.uuid, trial: 3)
    Stripe::Subscription.create({
                                  customer: customer_id,
                                  trial_end: trial.days.since.to_i,
                                  items: [{ plan: Plan.standard_plan.id }]
                                }, {
                                  idempotency_key: idempotency_key
                                })
  end

  def destroy(subscription_id)
    Stripe::Subscription.update(subscription_id, cancel_at_period_end: true)
  end

  def all
    Stripe::Subscription.list({ status: 'all' }).auto_paging_each.map { |sub| sub }
  end
end
