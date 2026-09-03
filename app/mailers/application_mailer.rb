# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'フィヨルドブートキャンプ <noreply@bootcamp.fjord.jp>'
  layout 'mailer'

  rescue_from Postmark::InactiveRecipientError, with: :mailerror

  private

  def mailerror(exception)
    Rails.logger.info(exception.recipients.to_s)
  end
end
