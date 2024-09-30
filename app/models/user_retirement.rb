# frozen_string_literal: true

class UserRetirement
  def initialize(user)
    @user = user
  end

  def execute
    @user.clear_github_data
    destroy_subscription
    destroy_card
    notify_to_user
    notify_to_admins
    notify_to_mentors
  end

  private

  def destroy_subscription
    Subscription.new.destroy(@user.subscription_id) if @user.subscription_id?
  end

  def destroy_card
    Card.destroy_all(@user.customer_id) if @user.customer_id?
  end

  def notify_to_user
    UserMailer.retire(@user).deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  end

  def notify_to_admins
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: @user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_to_mentors
    User.mentor.each do |mentor_user|
      ActivityDelivery.with(sender: @user, receiver: mentor_user).notify(:retired)
    end
  end
end
