# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  def incoming(inquiry)
    @inquiry = inquiry
    mail to: 'info@lokka.jp', reply_to: @inquiry.email, subject: '[FBC] お問い合わせ'
  end
end
