# frozen_string_literal: true

class MentorsWatchForQuestionCreator
  def call(_name, _started, _finished, _unique_id, payload)
    question = payload[:question]
    return if question.wip? || question.watched?

    Watch.register_all(watchable: question, users: User.mentor)
  end
end
