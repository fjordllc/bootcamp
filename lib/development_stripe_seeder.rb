# frozen_string_literal: true

class DevelopmentStripeSeeder
  def initialize(customer_gateway: Stripe::Customer, card: Card.new, subscription: Subscription.new, api_key: Stripe.api_key)
    @customer_gateway = customer_gateway
    @card = card
    @subscription = subscription
    @api_key = api_key
  end

  def call
    raise 'This seeder is only available in development.' unless Rails.env.development?
    raise 'Stripe test mode API key is required.' unless @api_key&.start_with?('sk_test_', 'rk_test_')

    User.where.not(subscription_id: nil).find_each do |user|
      seed(user)
      Rails.logger.info "Seeded Stripe data for #{user.login_name}"
    end
  end

  def seed(user)
    customer, customer_created = find_or_create_customer(user)
    if customer_created
      destroy_existing_subscription(user)
      stripe_subscription = create_subscription(customer)
    else
      stripe_subscription = find_or_create_subscription(user, customer)
    end
    @subscription.destroy(stripe_subscription.id) if user.hibernated?

    user.update_columns(customer_id: customer.id, subscription_id: stripe_subscription.id) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def find_or_create_customer(user)
    return [@card.create(user, 'tok_visa'), true] unless user.customer_id?

    customer = @customer_gateway.retrieve(user.customer_id)
    return [@card.create(user, 'tok_visa'), true] if customer.default_source.blank?

    [customer, false]
  rescue Stripe::InvalidRequestError
    [@card.create(user, 'tok_visa'), true]
  end

  def find_or_create_subscription(user, customer)
    @subscription.retrieve(user.subscription_id)
  rescue Stripe::InvalidRequestError
    create_subscription(customer)
  end

  def create_subscription(customer)
    @subscription.create(customer.id, trial: 0)
  end

  def destroy_existing_subscription(user)
    @subscription.destroy(user.subscription_id) if user.subscription_id?
  rescue Stripe::InvalidRequestError
    nil
  end
end
