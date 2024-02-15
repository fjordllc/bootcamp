# frozen_string_literal: true

class CorporateTrainingMailer < ApplicationMailer
  def incoming(corporate_training)
    @corporate_training = corporate_training
    mail to: 'info@lokka.jp', reply_to: @corporate_training.email, subject: '[FBC] 企業研修の申し込み'
  end
end
