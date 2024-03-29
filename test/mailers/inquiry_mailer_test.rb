# frozen_string_literal: true

require 'test_helper'

class InquiryMailerTest < ActionMailer::TestCase
  test 'incoming' do
    inquiry = Inquiry.new(
      name: '駒形真幸',
      email: 'komagata@example.com',
      body: "お問い合わせ内容\nあああ\nいいい\nううう"
    )
    mail = InquiryMailer.incoming(inquiry)
    assert_equal '[FBC] お問い合わせ', mail.subject
    assert_equal ['info@lokka.jp'], mail.to
    assert_equal ['noreply@bootcamp.fjord.jp'], mail.from
    assert_equal ['komagata@example.com'], mail.reply_to
    assert_match(/お問い合わせ/, mail.body.to_s)
  end
end
