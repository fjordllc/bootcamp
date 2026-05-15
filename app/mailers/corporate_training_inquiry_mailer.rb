# frozen_string_literal: true

class CorporateTrainingInquiryMailer < ApplicationMailer
  def incoming(corporate_training_inquiry)
    @corporate_training_inquiry = corporate_training_inquiry
    mail to: 'info@lokka.jp', reply_to: @corporate_training_inquiry.email, subject: '[FBC] 企業研修の申し込み'
  end
end
