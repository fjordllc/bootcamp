# frozen_string_literal: true

class Scheduler::Daily::SendMailToHibernationUserController < SchedulerController
  def show
    send_mail_one_week_before_auto_retire
    head :ok
  end

  private

  def send_mail_one_week_before_auto_retire
    User.unretired.hibernated_for(User::HIBERNATION_LIMIT_BEFORE_ONE_WEEK).each do |user|
      if user.auto_retire && !user.sent_student_before_auto_retire_mail
        UserMailer.one_week_before_auto_retire(user).deliver_now
        user.mark_mail_as_sent_before_auto_retire
      end
    rescue Postmark::InactiveRecipientError => e
      Rails.logger.warn "[Postmark] 受信者由来のエラーのためメールを送信できませんでした。：#{e.message}"
    end
  end
end
