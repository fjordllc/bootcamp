# frozen_string_literal: true

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:komagata)
    email = UserMailer.welcome(user).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "フィヨルドブートキャンプへようこそ", email.subject
    assert_match %r{ご応募ありがとうございます}, email.body.to_s
  end
end
