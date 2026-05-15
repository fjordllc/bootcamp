# frozen_string_literal: true

class AnswererWatcher
  def call(_name, _started, _finished, _unique_id, payload)
    answer = payload[:answer]
    question = Question.find(answer.question_id)

    return if question.watches.pluck(:user_id).include?(answer.sender.id)

    @watch = Watch.new(
      user: answer.sender,
      watchable: question
    )
    @watch.save!
  end
end
