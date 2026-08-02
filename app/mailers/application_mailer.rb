# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'フィヨルドブートキャンプ <noreply@bootcamp.fjord.jp>'
  layout 'mailer'

  after_action :stopped_mail_by_admin

  private

  def stopped_mail_by_admin
    if @user&.stopped_mail_by_admin?
      mail.perform_deliveries = false
    end
  end
end
