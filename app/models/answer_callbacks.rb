# frozen_string_literal: true

class AnswerCallbacks
  def after_create(answer)
    if answer.sender != answer.reciever
      notify_answer(answer)
    end

    create_watch(answer)
    notify_to_watching_user(answer)
  end

  private
    def notify_answer(answer)
      Notification.came_answer(answer)
    end

    def notify_to_watching_user(answer)
      question = Question.find(answer.question_id)

      if question.try(:watched?)
        watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
        watcher_ids.each do |watcher_id|
          if watcher_id != answer.sender.id
            watcher = User.find_by(id: watcher_id)
            Notification.watching_notification(question, watcher)
          end
        end
      end
    end

    def create_watch(answer)
      question = Question.find(answer.question_id)

      unless question.watches.pluck(:user_id).include?(answer.sender.id)
        @watch = Watch.new(
          user: answer.sender,
          watchable: question
        )
        @watch.save!
      end
    end
end
