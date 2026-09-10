# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'フィヨルドブートキャンプ <noreply@bootcamp.fjord.jp>'
  layout 'mailer'

  rescue_from Postmark::InactiveRecipientError, with: :mailerror

  private

  def mailerror(exception)
    masked_recipients = exception.recipients.map { |email| mask_email(email) }
    Rails.logger.info(masked_recipients.to_s)
  end

  def mask_email(email)
    local, domain = email.split('@')
    "#{local[0]}***@#{domain}"
  end
end
