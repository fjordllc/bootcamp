# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    notify_certain_period_passed_after_retirement
    notify_tomorrow_regular_event
    notify_product_review_not_completed
    head :ok
  end

  private

  def notify_certain_period_passed_after_retirement
    User.retired.find_each do |retired_user|
      if retired_user.retired_three_months_ago_and_notification_not_sent?
        User.admins.each do |admin_user|
          NotificationFacade.three_months_after_retirement(retired_user, admin_user)
          retired_user.update!(notified_retirement: true)
        end
      end
    end
  end

  def notify_tomorrow_regular_event
    return if RegularEvent.tomorrow_events.blank?

    RegularEvent.tomorrow_events.each do |regular_event|
      NotificationFacade.tomorrow_regular_event(regular_event)
    end
  end

  def notify_product_review_not_completed
    Comment.where(commentable_type: 'Product').find_each do |product_comment|
      product = product_comment.commentable
      if product_comment.certain_period_passed_since_the_last_comment_by_submitter?(5.days) && !product.unassigned? && !product.checked?
        DiscordNotifier.with(comment: product_comment).product_review_not_completed.notify_now
      end
    end

    Question.notify_questioner_to_choose_correct_answer if Question.not_solved_and_a_week_has_passed.present?
    head :ok
  end
end
