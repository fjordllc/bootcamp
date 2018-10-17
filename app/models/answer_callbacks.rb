class AnswerCallbacks
  def after_create(answer)
    send_notification(answer)
  end

  private
    def send_notification(answer)
      Notification.came_answer(answer)
    end
end
