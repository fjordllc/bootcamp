# frozen_string_literal: true

class AnswerNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    answer = payload[:answer]
    return if answer.sender == answer.receiver

    question = answer.question
    watcher_ids = Watch.where(watchable_id: question.id).pluck(:user_id)
    mention_user_ids = answer.new_mention_users.ids
    ActivityDelivery.with(answer:).notify(:came_answer) if watcher_ids.concat(mention_user_ids).exclude?(answer.receiver.id)
  end
end
