# frozen_string_literal: true

class ComebackUser
  include Interactor

  def call
    update_last_returned_at!
    create_subscription_if_needed
    clear_hibernation
  end

  private

  def update_last_returned_at!
    hibernation = context.user.last_hibernation
    hibernation.returned_at = Date.current
    hibernation.save!(validate: false)
  end

  def create_subscription_if_needed
    return unless Rails.env.production? && ENV['DB_NAME'] != 'bootcamp_staging'

    subscription = Subscription.new.create(context.user.customer_id, trial: 0)
    context.user.subscription_id = subscription['id']
  end

  def clear_hibernation
    context.user.hibernated_at = nil
    context.user.save!(validate: false)
  end
end
