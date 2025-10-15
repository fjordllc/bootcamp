# frozen_string_literal: true

class Retirement
  def initialize(user, triggered_by:)
    @user = user
    @handler = role_handler(triggered_by)
  end

  def call(params = nil)
    @user.retired_on = Date.current
    @user.hibernated_at = nil

    return false unless @handler.save_user(params)

    notify_and_cleanup

    true
  end

  def notify_and_cleanup
    clean_up

    type = @handler.notification_type
    notify_user(type) if @handler.notify_user
    notify_admins_and_mentors if @handler.notify_admins_and_mentors
  end

  private

  def clean_up
    Newspaper.publish(:retirement_create, { user: @user })
    destroy_subscription
    @handler.additional_clean_up
  end

  def destroy_subscription
    Subscription.new.destroy(@user.subscription_id) if @user.subscription_id?
  end

  def notify_user(event)
    UserMailer.send(event, @user).deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  end

  def notify_admins_and_mentors
    User.admins_and_mentors.each do |admin_user|
      ActivityDelivery.with(sender: @user, receiver: admin_user).notify(:retired)
    end
  end

  def role_handler(triggered_by)
    case triggered_by
    when 'user'
      RetirementHandler::User.new(@user)
    when 'admin'
      RetirementHandler::Admin.new
    when 'hibernation'
      RetirementHandler::Hibernation.new(@user)
    end
  end
end
