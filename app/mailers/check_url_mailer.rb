# frozen_string_literal: true

class CheckUrlMailer < ApplicationMailer
  def notify_error_url(docs_error_url, practice_error_url)
    @docs_error_url = docs_error_url
    @practice_error_url = practice_error_url
    mail to: "info@fjord.jp", subject: "[Bootcamp] リンク切れURLを発見"
  end
end
