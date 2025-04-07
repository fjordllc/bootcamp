# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'welcome' do
    user = users(:komagata)
    email = UserMailer.welcome(user).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] フィヨルドブートキャンプへようこそ', email.subject
    assert_match(/お申し込みありがとうございます/, email.body.to_s)
  end

  test 'retire' do
    user = users(:kimura)
    email = UserMailer.retire(user).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal ['info@lokka.jp'], email.bcc
    assert_equal '[FBC] 退会処理が完了しました', email.subject
    assert_match(/ご利用いただき誠にありがとうございました/, email.body.to_s)
    assert_match("#{user.name}様の今後のご活躍を心からお祈り申し上げます。", email.body.to_s)
  end

  test 'training_complete' do
    user = users(:kensyu)
    email = UserMailer.training_complete(user).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kensyu@fjord.jp'], email.to
    assert_equal ['info@lokka.jp'], email.bcc
    assert_equal '[FBC] 研修終了手続きが完了しました', email.subject
    assert_match("#{user.name}様の今後のご活躍を心からお祈り申し上げます。", email.body.to_s)
  end

  test 'request_retirement' do
    requester = users(:senpai)
    target_user = users(:kensyuowata)

    request_retirement = RequestRetirement.new(
      user_id: requester.id,
      target_user_id: target_user.id,
      reason: '退職してしまったため。',
      keep_data: true
    )

    email = UserMailer.request_retirement(request_retirement).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['senpai@fjord.jp'], email.to
    assert_equal ['info@lokka.jp'], email.bcc
    assert_equal '[FBC] 退会申請を受け付けました', email.subject
    assert_match(/以下の内容で退会申請を受け付けました。/, email.body.to_s)
  end
end
