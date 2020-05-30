# frozen_string_literal: true

class BrokenLinkMailer < ApplicationMailer
  def notify_error_url(url)
    @url_array = url
    mail to: "info@fjord.jp", subject: "[Bootcamp] URLのリンク切れ"
  end
end
