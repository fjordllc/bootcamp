# frozen_string_literal: true

class QuestionNotifier
  def call(question)
    return if question.wip?

    notify_to_chat(question)
  end

  private

  def notify_to_chat(question)
    ChatNotifier.message(<<~TEXT)
      質問：「#{question.title}」を#{question.user.login_name}さんが作成しました。
      #{Rails.application.routes.url_helpers.question_url(question)}
    TEXT
  end
end
