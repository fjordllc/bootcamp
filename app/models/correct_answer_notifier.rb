# frozen_string_literal: true

class CorrectAnswerNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    answer = payload[:answer]
    notify_correct_answer(answer)
    notify_to_chat(answer)
  end

  private

  def notify_correct_answer(answer)
    question = answer.question
    watcher_ids = question.watches.pluck(:user_id)
    receiver_ids = watcher_ids - [question.user_id]
    receiver_ids.each do |receiver_id|
      receiver = User.find(receiver_id)
      ActivityDelivery.with(answer:, receiver:).notify(:chose_correct_answer)
    end
  end

  def notify_to_chat(answer)
    url_options = Rails.application.config.action_controller.default_url_options || {}
    question_url = Rails.application.routes.url_helpers.question_url(answer.question, url_options)
    ChatNotifier.message("質問：「#{answer.question.title}」のベストアンサーが選ばれました。\r#{question_url}")
  end
end
