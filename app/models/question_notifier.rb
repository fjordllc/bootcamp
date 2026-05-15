# frozen_string_literal: true

class QuestionNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    question = payload[:question]
    return if question.wip?

    ChatNotifier.message(<<~TEXT)
      質問：「#{question.title}」を#{question.user.login_name}さんが作成しました。
      <#{Rails.application.routes.url_helpers.question_url(question)}>
    TEXT
  end
end
