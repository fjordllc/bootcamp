# frozen_string_literal: true

class AfterUserRetirement
  def initialize(user, triggered_by:)
    @user = user
    @triggered_by = triggered_by
  end

  def call
    Newspaper.publish(:retirement_create, { user: @user })
    destroy_subscription

    case @triggered_by
    when 'admin'
      admin_steps
    when 'hibernation'
      hibernation_steps
    when 'user'
      user_steps
    end
  end

  private

  def admin_steps
    # アドミンによる退会処理を追加する場合ここに書く
  end

  def hibernation_steps
    notify_all(:auto_retire)
  end

  def user_steps
    notify_all(:retire)
    destroy_card
    @user.clear_github_data
  end

  def destroy_subscription
    Subscription.new.destroy(@user.subscription_id) if @user.subscription_id?
  end

  def destroy_card
    Card.destroy_all(@user.customer_id) if @user.customer_id?
  end

  def notify_all(event)
    notify_admins
    notify_mentors
    notify_user(event)
  end

  def notify_user(event)
    UserMailer.send(event, @user).deliver_now
  rescue Postmark::InactiveRecipientError => e
    Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
  end

  def notify_admins
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: @user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_mentors
    User.mentors_excluding_admins.each do |mentor_user|
      ActivityDelivery.with(sender: @user, receiver: mentor_user).notify(:retired)
    end
  end
end
