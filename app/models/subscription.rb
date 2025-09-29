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
    # Safely read tax_rate_id with string/symbol fallback
    config = Rails.application.config_for(:secrets)
    tax_rate_id = config.dig('stripe', 'tax_rate_id') ||
                  config.dig(:stripe, :tax_rate_id)

    # Validate presence and fail fast with clear error
    raise KeyError, 'Stripe tax_rate_id is not configured. Set stripe.tax_rate_id in secrets configuration.' if tax_rate_id.blank?

    options = {
      customer: customer_id,
      items: [{
        plan: Plan.standard_plan.id,
        tax_rates: [tax_rate_id]
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
