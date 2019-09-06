# frozen_string_literal: true

class CommentCallbacks
  def before_save(comment)
    notify_mention(comment) if comment.new_mentions?
  end

  def after_create(comment)
    if comment.sender != comment.reciever
      notify_comment(comment)
    end

    if [Report, Product].include?(comment.commentable.class)
      create_watch(comment)
      notify_to_watching_user(comment)
    end
  end

  private
    def notify_mention(comment)
      comment.new_mentions.each do |mention|
        reciever = User.find_by(login_name: mention)
        if reciever && comment.sender != reciever
          NotificationFacade.mentioned(comment, reciever)
        end
      end
    end

    def notify_comment(comment)
      NotificationFacade.came_comment(
        comment,
        comment.reciever,
        "#{comment.sender.login_name}さんからコメントが届きました。"
      )
    end

    def notify_to_watching_user(comment)
      watchable = comment.commentable

      if watchable.try(:watched?)
        watcher_ids = watchable.watches.pluck(:user_id)
        watcher_ids.each do |watcher_id|
          if watcher_id != comment.sender.id
            watcher = User.find_by(id: watcher_id)
            NotificationFacade.watching_notification(watchable, watcher)
          end
        end
      end
    end

    def create_watch(comment)
      watchable = comment.commentable

      unless watchable.watches.pluck(:user_id).include?(comment.sender.id)
        @watch = Watch.new(
          user: comment.sender,
          watchable: watchable
        )
        @watch.save!
      end
    end
end
