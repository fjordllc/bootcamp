# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    notify_product_review_not_completed
    head :ok
  end

  private

  def notify_product_review_not_completed
    Comment.where(commentable_type: 'Product').find_each do |product_comment|
      product = product_comment.commentable
      if product_comment.certain_period_passed_since_the_last_comment_by_submitter?(5.days) && !product.unassigned? && !product.checked?
        DiscordNotifier.with(comment: product_comment).product_review_not_completed.notify_now
      end
    end
  end
end
