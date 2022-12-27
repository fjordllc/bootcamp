# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    notify_tomorrow_regular_event
    notify_product_review_not_completed
    Question.notify_certain_period_passed_after_last_answer
    head :ok
  end

  private

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
  end
end
