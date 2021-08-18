# frozen_string_literal: true

class CommentCallbacks
  def after_create(comment)
    if comment.commentable.class.include?(Watchable)
      create_watch(comment)
      notify_to_watching_user(comment)
    elsif comment.sender != comment.receiver
      notify_comment(comment)
    end

    return unless comment.commentable.instance_of?(Product)

    update_last_comment_at(comment)
    delete_product_cache(comment.commentable.id)
  end

  def after_update(comment)
    return unless comment.commentable.instance_of?(Product)

    update_last_comment_at(comment)
  end

  def after_destroy(comment)
    return unless comment.commentable.instance_of?(Product)

    delete_product_cache(comment.commentable.id)
  end

  private

  def update_last_comment_at(comment)
    product = Product.find(comment.commentable.id)
    if comment.user.mentor
      product.mentor_last_comment_at = comment.updated_at
      product.save!
    elsif comment.user == product.user
      product.self_last_comment_at = comment.updated_at
      product.save!
    end
  end

  def notify_comment(comment)
    NotificationFacade.came_comment(
      comment,
      comment.receiver,
      "#{comment.sender.login_name}さんからコメントが届きました。"
    )
  end

  def notify_to_watching_user(comment)
    watchable = comment.commentable
    mention_user_ids = comment.new_mention_users.ids

    return unless watchable.try(:watched?)

    watcher_ids = watchable.watches.pluck(:user_id)
    watcher_ids.each do |watcher_id|
      if watcher_id != comment.sender.id && !mention_user_ids.include?(watcher_id)
        watcher = User.find_by(id: watcher_id)
        NotificationFacade.watching_notification(watchable, watcher, comment)
      end
    end
  end

  def create_watch(comment)
    watchable = comment.commentable

    return if watchable.watches.pluck(:user_id).include?(comment.sender.id)

    @watch = Watch.new(
      user: comment.sender,
      watchable: watchable
    )
    @watch.save!
  end

  def delete_product_cache(product_id)
    Rails.cache.delete "/model/product/#{product_id}/last_commented_user"
    Cache.delete_not_responded_product_count
  end
end
