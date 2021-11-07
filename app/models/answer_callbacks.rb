# frozen_string_literal: true

class AnswerCallbacks
  def after_create(answer)
    notify_answer(answer)
    create_watch(answer)
    notify_to_watching_user(answer)
  end

  def after_save(answer)
    notify_correct_answer(answer) if answer.saved_change_to_attribute?('type', to: 'CorrectAnswer')

    Cache.delete_not_solved_question_count
  end

  def after_destroy(_answer)
    Cache.delete_not_solved_question_count
  end

  private

  def notify_answer(answer)
    question = answer.question
    watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
    mention_user_ids = answer.new_mention_users.ids

    return unless answer.sender != answer.receiver
    return if mention_user_ids.include?(answer.receiver.id)
    return if watcher_ids.include?(answer.receiver.id)

    NotificationFacade.came_answer(answer)
  end

  def notify_to_watching_user(answer)
    question = Question.find(answer.question_id)
    mention_user_ids = answer.new_mention_users.ids

    return unless question.try(:watched?)

    watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
    watcher_ids.each do |watcher_id|
      if watcher_id != answer.sender.id && !mention_user_ids.include?(watcher_id)
        watcher = User.find_by(id: watcher_id)
        NotificationFacade.watching_notification(question, watcher, answer)
      end
    end
  end

  def notify_correct_answer(answer)
    question = answer.question
    watcher_ids = question.watches.pluck(:user_id)
    receiver_ids = watcher_ids - [question.user_id]
    receiver_ids.each do |receiver_id|
      receiver = User.find(receiver_id)
      NotificationFacade.chose_correct_answer(answer, receiver)
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
