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
    options = {
      customer: customer_id,
      items: [{
        plan: Plan.standard_plan.id,
        tax_rates: [Rails.application.secrets[:stripe][:tax_rate_id]]
      }]
    }
    options[:trial_end] = trial.days.since.to_i if trial.positive?

    Stripe::Subscription.create(options, { idempotency_key: })
  end

  def destroy(subscription_id)
    return true if retrieve(subscription_id).status == 'canceled'

    Stripe::Subscription.update(subscription_id, cancel_at_period_end: true)
  end

  def all
    Stripe::Subscription.list({ status: 'all' }).auto_paging_each.map { |sub| sub }
  end
end
