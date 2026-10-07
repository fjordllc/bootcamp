# frozen_string_literal: true

class AnswererWatcher
  def call(_name, _started, _finished, _unique_id, payload)
    answer = payload[:answer]
    question = Question.find(answer.question_id)

    Watch.register!(user: answer.sender, watchable: question)
  end
end
