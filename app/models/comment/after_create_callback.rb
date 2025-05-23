# frozen_string_literal: true

class Comment::AfterCreateCallback
  def after_commit(comment)
    if comment.commentable.class.include?(Watchable)
      create_watch(comment)
      notify_to_watching_user(comment)
    elsif comment.receiver.present? && comment.receiver != comment.sender
      Newspaper.publish(:came_comment, { comment: })
    end

    if comment.commentable.instance_of?(Talk)
      notify_to_admins(comment)
      unless comment.sender.admin?
        notify_to_chat(comment)
        update_action_completed(comment)
      end
    end

    return unless comment.commentable.instance_of?(Product)

    comment.commentable.update_last_commented_at(comment)
    comment.commentable.update_commented_at(comment)
    delete_product_cache(comment.commentable.id)
    delete_assigned_and_unreplied_product_count_cache(comment)
  end

  private

  def notify_to_watching_user(comment)
    watchable = comment.commentable
    mention_user_ids = comment.new_mention_users.ids

    return unless watchable.try(:watched?)

    watcher_ids = watchable.watches.pluck(:user_id)
    watcher_ids.each do |watcher_id|
      next unless watcher_id != comment.sender.id && !mention_user_ids.include?(watcher_id)

      watcher = User.find_by(id: watcher_id)
      sender = comment.sender

      ActivityDelivery.with(
        watchable:,
        receiver: watcher,
        comment:,
        sender:
      ).notify(:watching_notification)
    end
  end

  def create_watch(comment)
    watchable = comment.commentable

    return if watchable.watches.pluck(:user_id).include?(comment.sender.id)

    @watch = Watch.new(
      user: comment.sender,
      watchable:
    )
    @watch.save!
  end

  def delete_product_cache(product_id)
    Rails.cache.delete "/model/product/#{product_id}/last_commented_user"
  end

  def delete_assigned_and_unreplied_product_count_cache(comment)
    product = comment.commentable

    return unless product.checker_id.present? && product.replied_status_changed?(comment.previous&.user_id, comment.user_id)

    Cache.delete_self_assigned_no_replied_product_count(product.checker_id)
  end

  def notify_to_admins(comment)
    Newspaper.publish(:came_comment_in_talk, { comment: })
  end

  def update_action_completed(comment)
    comment.commentable.update!(action_completed: false)
  end

  def notify_to_chat(comment)
    ChatNotifier.message(<<~TEXT, webhook_url: ENV['DISCORD_ADMIN_WEBHOOK_URL'])
      相談部屋にて#{comment.user.login_name}さんからコメントがありました。
      本文： #{comment.description}
      URL： <https://bootcamp.fjord.jp/talks/#{comment.commentable_id}#latest-comment>
    TEXT
  end
end
