# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    notify_three_months_after_retirement
    notify_tomorrow_regular_event
    notify_product_review_not_completed
    head :ok
  end

  private

  def notify_three_months_after_retirement
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
    if RegularEvent.tomorrow_events.present?
      RegularEvent.tomorrow_events.each do |regular_event|
        NotificationFacade.tomorrow_regular_event(regular_event)
      end
    end
  end

  def notify_product_review_not_completed
    Comment.where(commentable_type: 'Product').find_each do |product_comment|
      product = product_comment.commentable
      if product_comment.five_days_since_the_last_comment_by_submitter? && !product.unassigned? && !product.checked?
        NotificationFacade.product_review_not_completed(product_comment)
      end
    end
  end
end
