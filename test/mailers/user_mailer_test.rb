# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'welcome' do
    user = users(:komagata)
    email = UserMailer.welcome(user).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[bootcamp] フィヨルドブートキャンプへようこそ', email.subject
    assert_match(/お申し込みありがとうございます/, email.body.to_s)
  end

  test 'retire' do
    user = users(:kimura)
    email = UserMailer.retire(user).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal 'フィヨルドブートキャンプお礼', email.subject
    assert_match(/今までお疲れ様です/, email.body.to_s)
  end
end
