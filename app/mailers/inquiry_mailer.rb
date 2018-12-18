# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  def incoming(inquiry)
    @inquiry = inquiry
    mail to: "info@fjord.jp", from: @inquiry.email, subject: "[Bootcamp] お問い合わせ"
  end
end
