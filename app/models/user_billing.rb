# frozen_string_literal: true

class UserBilling
  def initialize(user)
    @user = user
  end

  def customer
    return unless @user.customer_id?

    Customer.new.retrieve(@user.customer_id)
  end

  def card?
    @user.customer_id?
  end

  alias paid? card?

  def card
    customer.sources.data.first
  end

  def subscription?
    @user.subscription_id?
  end

  def subscription
    return unless subscription?

    Subscription.new.retrieve(@user.subscription_id)
  end
end
