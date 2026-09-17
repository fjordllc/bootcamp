# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'フィヨルドブートキャンプ <noreply@bootcamp.fjord.jp>'
  layout 'mailer'

  rescue_from Postmark::InactiveRecipientError, with: :mailerror

  private

  def mailerror(exception)
    masked_recipients = exception.recipients.map { |email| mask_email(email) }
    Rails.logger.info("Postmarkの配信停止済みアドレスへの送信をスキップしました: #{masked_recipients}")
  end

  def mask_email(email)
    local, domain = email.split('@')
    "#{local[0]}***@#{domain}"
  end
end
