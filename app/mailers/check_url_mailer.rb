# frozen_string_literal: true

class CheckUrlMailer < ApplicationMailer
  def notify_error_url(page_error_url, practice_error_url)
    @page_error_url = page_error_url
    @practice_error_url = practice_error_url
    mail to: "info@fjord.jp", subject: "[BootCamp Admin] リンク切れ報告"
  end
end
