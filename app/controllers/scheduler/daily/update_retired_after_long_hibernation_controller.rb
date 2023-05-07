# frozen_string_literal: true

class Scheduler::Daily::UpdateRetiredAfterLongHibernationController < SchedulerController
  def show
    update_retired_after_long_hibernation
    head :ok
  end

  private

  def update_retired_after_long_hibernation
    User.unretired.hibernated_for(3.months).auto_retire_after_long_hibernation each do |user|
      user.retire_reason = '（休会後三ヶ月経過したため自動退会）'
      user.retired_on = Date.current
      user.save!(validate: false)

      Newspaper.publish(:retirement_create, user)
      begin
        UserMailer.retire(user).deliver_now
      rescue Postmark::InactiveRecipientError => e
        logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
      end

      destroy_subscription
      notify_to_admins
      notify_to_mentors
    end
  end

  def destroy_subscription
    Subscription.new.destroy(current_user.subscription_id) if current_user.subscription_id
  end

  def notify_to_admins
    User.admins.each do |admin_user|
      ActivityDelivery.with(sender: current_user, receiver: admin_user).notify(:retired)
    end
  end

  def notify_to_mentors
    User.mentor.each do |mentor_user|
      ActivityDelivery.with(sender: current_user, receiver: mentor_user).notify(:retired)
    end
  end
end
