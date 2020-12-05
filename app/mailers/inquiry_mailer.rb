# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  def incoming(inquiry)
    @inquiry = inquiry
    mail to: 'info@fjord.jp', reply_to: @inquiry.email, subject: '[Bootcamp] お問い合わせ'
  end
end
