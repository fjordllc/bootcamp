# frozen_string_literal: true

class MentorsWatchForQuestionCreator
  def call(_name, _started, _finished, _unique_id, payload)
    question = payload[:question]
    return if question.wip? || question.watched?

    watch_question_records = watch_records(question)
    Watch.insert_all(watch_question_records) # rubocop:disable Rails/SkipsModelValidations
  end

  def watch_records(question)
    User.mentor.map do |mentor|
      {
        watchable_type: 'Question',
        watchable_id: question.id,
        created_at: Time.current,
        updated_at: Time.current,
        user_id: mentor.id
      }
    end
  end
end
