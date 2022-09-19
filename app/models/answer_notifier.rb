# frozen_string_literal: true

class AnswerNotifier
  def call(answer)
    notify_answer(answer)
    create_watch(answer)
  end

  private

  def notify_answer(answer)
    return if answer.sender == answer.receiver

    question = answer.question
    watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
    mention_user_ids = answer.new_mention_users.ids
    NotificationFacade.came_answer(answer) if watcher_ids.concat(mention_user_ids).exclude?(answer.receiver.id)
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
