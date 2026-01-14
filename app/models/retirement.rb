# frozen_string_literal: true

# strategyパターンの簡易版
# 各退会ケース(Self, Auto, Admin)のStrategyクラスを利用
class Retirement
  def initialize(user:, strategy:)
    @user = user
    @strategy = strategy
  end

  def self.by_self(params, user:)
    new(user:, strategy: Retirement::Self.new(params))
  end

  def self.auto(user:)
    new(user:, strategy: Retirement::Auto.new)
  end

  def self.by_admin(user:)
    new(user:, strategy: Retirement::Admin.new)
  end

  def execute
    ActiveRecord::Base.transaction do
      assign_reason
      assign_date
      clear_hibernation_state
      save_user
      destroy_subscription
    end

    handle_regular_events_on_retirement

    clear_github_info
    destroy_cards
    publish
    notify
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to save user: #{e.message}"
    false
  rescue Stripe::StripeError => e
    Rails.logger.error "Failed to delete subscription: #{e.message}"
    false
  end

  private

  def assign_reason
    @strategy.assign_reason(@user)
  end

  def assign_date
    @strategy.assign_date(@user)
  end

  def clear_hibernation_state
    @user.hibernated_at = nil
  end

  def save_user
    @strategy.save_user(@user)
  end

  def destroy_subscription
    Subscription.new.destroy(@user.subscription_id) if @user.subscription_id?
  end

  def clear_github_info
    @user.clear_github_data
  end

  def destroy_cards
    Card.destroy_all(@user.customer_id) if @user.customer_id?
  end

  def cancel_event_subscription
    @user.cancel_participation_from_regular_events
  end

  def remove_as_event_organizer
    @user.delete_and_assign_new_organizer
  end

  def publish
    ActiveSupport::Notifications.instrument('retirement.create', user: @user)
  end

  def notify
    return unless (type = @strategy.notification_type)

    notify_user(type)
    notify_admins_and_mentors
  end

  def notify_user(type)
    UserMailer.send(type, @user).deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  end

  def notify_admins_and_mentors
    User.admins_and_mentors.each do |admin_user|
      ActivityDelivery.with(sender: @user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_to_new_regular_event_organizer(regular_events_and_organizers)
    regular_events_and_organizers.each do |regular_event_and_organizer|
      ActiveSupport::Notifications.instrument('organizer.create',
                                              regular_event: regular_event_and_organizer[:regular_event],
                                              before_organizer_ids: regular_event_and_organizer[:before_organizer_ids],
                                              sender: @user)
    end
  end

  def handle_regular_events_on_retirement
    captured_regular_events_and_organizers = @user.capture_before_regular_event_organizers
    cancel_event_subscription
    remove_as_event_organizer
    notify_to_new_regular_event_organizer(captured_regular_events_and_organizers)
  end
end
