# frozen_string_literal: true

class CommentCallbacks
  def after_create(comment)
    if comment.commentable.class.include?(Watchable)
      create_watch(comment)
      notify_to_watching_user(comment)
    elsif comment.sender != comment.receiver
      notify_comment(comment)
    elsif comment.commentable.instance_of?(Talk)
      notify_to_admins(comment)
    end

    return unless comment.commentable.instance_of?(Product)

    update_last_commented_at(comment)
    update_commented_at(comment)
    delete_product_cache(comment.commentable.id)
  end

  def after_update(comment)
    return unless comment.commentable.instance_of?(Product)

    update_last_commented_at(comment)
    update_commented_at(comment)
  end

  def after_destroy(comment)
    return unless comment.commentable.instance_of?(Product)

    delete_last_commented_at(comment.commentable.id)
    delete_commented_at(comment)
    delete_product_cache(comment.commentable.id)
  end

  private

  def reset_last_commented_at(product)
    product.mentor_last_commented_at = nil
    product.self_last_commented_at = nil
  end

  def delete_last_commented_at(product_id)
    product = Product.find(product_id)

    reset_last_commented_at(product)

    product.comments.each do |comment|
      if comment.user.mentor
        product.mentor_last_commented_at = comment.updated_at
      elsif comment.user == product.user
        product.self_last_commented_at = comment.updated_at
      end
    end
    product.save!
  end

  def update_last_commented_at(comment)
    product = Product.find(comment.commentable.id)
    if comment.user.mentor
      product.mentor_last_commented_at = comment.updated_at
    elsif comment.user == product.user
      product.self_last_commented_at = comment.updated_at
    end
    product.save!
  end

  def update_commented_at(comment)
    comment.commentable.update!(commented_at: comment.updated_at)
  end

  def delete_commented_at(comment)
    last_comment = comment.commentable.comments.last
    comment.commentable.commented_at = last_comment ? last_comment.updated_at : nil
    comment.commentable.save!
  end

  def notify_comment(comment)
    if comment.commentable.instance_of?(Talk)
      NotificationFacade.came_comment(
        comment,
        comment.receiver,
        "#{comment.sender.login_name}さんから相談部屋でコメントが届きました。"
      )
    else
      NotificationFacade.came_comment(
        comment,
        comment.receiver,
        "#{comment.sender.login_name}さんからコメントが届きました。"
      )
    end
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
  end

  def notify_to_admins(comment)
    User.admins.each do |admin_user|
      if comment.commentable.instance_of?(Talk)
        NotificationFacade.came_comment(
          comment,
          admin_user,
          "#{comment.sender.login_name}さんが相談部屋でコメントをしました。"
        )
      else
        NotificationFacade.came_comment(
          comment,
          comment.receiver,
          "#{comment.sender.login_name}さんからコメントが届きました。"
        )
      end
    end
  end
end
