class CommentCallbacks
  def before_save(comment)
    send_mention(comment) if comment.new_mentions?
  end

  def after_create(comment)
    if comment.sender != comment.reciever
      Notification.came_comment(comment)
    end
  end

  private

    def send_mention(comment)
      comment.new_mentions.each do |mention|
        reciever = User.find_by(login_name: mention)
        if reciever && comment.sender != reciever
          Notification.mentioned(comment, reciever)
        end
      end
    end
end
