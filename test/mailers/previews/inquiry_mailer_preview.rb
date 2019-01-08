# frozen_string_literal: true

class InquiryMailerPreview < ActionMailer::Preview
  def incoming
    inquiry = Inquiry.new(
      name: "駒形真幸",
      email: "komagata@example.com",
      body: "お問い合わせ内容\nあああ\nいいい\nううう"
    )
    InquiryMailer.incoming(inquiry)
  end
end
