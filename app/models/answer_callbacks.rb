# frozen_string_literal: true

class AnswerCallbacks
  def after_create(answer)
    notify_answer(answer) if answer.sender != answer.receiver

    create_watch(answer)
    notify_to_watching_user(answer)
  end

  def after_save(_answer)
    Cache.delete_not_solved_question_count
  end

  def after_destroy(_answer)
    Cache.delete_not_solved_question_count
  end

  private

  def notify_answer(answer)
    NotificationFacade.came_answer(answer)
  end

  def notify_to_watching_user(answer)
    question = Question.find(answer.question_id)

    retrun unless question.try(:watched?)
    watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
    watcher_ids.each do |watcher_id|
      if watcher_id != answer.sender.id
        watcher = User.find_by(id: watcher_id)
        NotificationFacade.watching_notification(question, watcher, answer)
      end
    end
  end

  def create_watch(answer)
    question = Question.find(answer.question_id)

    return if question.watches.pluck(:user_id).include?(answer.sender.id)

    @watch = Watch.new(
      user: answer.sender,
      watchable: question
    )
    @watch.save!
  end
end
