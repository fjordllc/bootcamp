# frozen_string_literal: true

require "test_helper"

class InquiryMailerTest < ActionMailer::TestCase
  test "incoming" do
    inquiry = Inquiry.new(
      name: "駒形真幸",
      email: "komagata@example.com",
      body: "お問い合わせ内容\nあああ\nいいい\nううう"
    )
    mail = InquiryMailer.incoming(inquiry)
    assert_equal "[Bootcamp] お問い合わせ", mail.subject
    assert_equal ["info@fjord.jp"], mail.to
    assert_equal ["komagata@example.com"], mail.from
    assert_match %r{お問い合わせ}, mail.body.to_s
  end
end
