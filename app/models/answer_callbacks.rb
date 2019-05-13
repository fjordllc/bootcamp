# frozen_string_literal: true

class AnswerCallbacks
  def after_create(answer)
    if answer.sender != answer.reciever
      notify_answer(answer)
      notify_to_watching_user(answer)
      create_watch(answer)
    end
  end

  private
    def notify_answer(answer)
      Notification.came_answer(answer)
    end

    def notify_to_watching_user(answer)
      question = Question.find(answer.question_id)
      watcher_id = Watch.where(watchable_id: question.id).pluck(:user_id)
      User.where(id: watcher_id).each do |watcher|
        Notification.watching_notification(question, watcher) unless watcher.id == answer.sender.id
      end
    end

    def create_watch(answer)
      @watch = Watch.new(
        user: answer.user,
        watchable: Question.find(answer.question_id)
      )
      @watch.save!
    end
end
