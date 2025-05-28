# frozen_string_literal: true

class Scheduler::Daily::AutoRetireController < SchedulerController
  def show
    auto_retire
    head :ok
  end

  private

  def auto_retire
    User.unretired.hibernated_for(User::HIBERNATION_LIMIT).auto_retire.each do |user|
      user.retire_reason = '（休会後三ヶ月経過したため自動退会）'
      user.retired_on = Date.current
      user.hibernated_at = nil
      user.save!(validate: false)

      Newspaper.publish(:retirement_create, { user: })
      begin
        UserMailer.auto_retire(user).deliver_now
      rescue Postmark::InactiveRecipientError => e
        logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
      end

      destroy_subscription(user)
      notify_to_admins(user)
      notify_to_mentors(user)
    end
  end

  def destroy_subscription(user)
    Subscription.new.destroy(user.subscription_id) if user.subscription_id.present?
  end

  def notify_to_admins(user)
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_to_mentors(user)
    User.mentor.each do |mentor_user|
      ActivityDelivery.with(sender: user, receiver: mentor_user).notify(:retired)
    end
  end
end
