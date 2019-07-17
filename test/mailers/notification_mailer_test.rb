# frozen_string_literal: true

require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "came_comment" do
    comment = comments(:comment_9)
    came_comment = inner_notifications(:notification_commented)
    email = NotificationMailer.came_comment(
      comment,
      came_comment.user,
      "#{comment.user.login_name}さんからコメントが届きました。"
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんからコメントが届きました。", email.subject
    assert_match %r{コメント}, email.body.to_s
  end

  test "checked" do
    check = checks(:report5_check_machida)
    email = NotificationMailer.checked(check).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] sotugyouさんの学習週1日目を確認しました。", email.subject
    assert_match %r{確認}, email.body.to_s
  end

  test "mentioned" do
    mention = comments(:comment_9)
    mentioned = inner_notifications(:notification_mentioned)
    email = NotificationMailer.mentioned(
      mention,
      mentioned.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんからメンションがきました。", email.subject
    assert_match %r{メンション}, email.body.to_s
  end

  test "submitted" do
    product = products(:product_3)
    submitted = inner_notifications(:notification_submitted)
    email = NotificationMailer.submitted(
      product,
      submitted.user,
      "#{product.user.login_name}さんが提出しました。"
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] sotugyouさんが提出しました。", email.subject
    assert_match %r{提出}, email.body.to_s
  end

  test "came_answer" do
    answer = answers(:answer_3)
    email = NotificationMailer.came_answer(answer).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんから回答がありました。", email.subject
    assert_match %r{回答}, email.body.to_s
  end

  test "post_announcement" do
    announce = announcements(:announcement_1)
    announced = inner_notifications(:notification_announced)
    email = NotificationMailer.post_announcement(
      announce,
      announced.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんからお知らせです。", email.subject
    assert_match %r{お知らせ}, email.body.to_s
  end

  test "came_question" do
    question = questions(:question_2)
    questioned = inner_notifications(:notification_questioned)
    email = NotificationMailer.came_question(
      question,
      questioned.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] sotugyouさんから質問がありました。", email.subject
    assert_match %r{質問}, email.body.to_s
  end

  test "first_report" do
    report = reports(:report_10)
    first_report = inner_notifications(:notification_first_report)
    email = NotificationMailer.first_report(
      report,
      first_report.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] hajimeさんがはじめての日報を書きました！", email.subject
    assert_match %r{はじめて}, email.body.to_s
  end

  test "watching_notification" do
    watch = watches(:report1_watch_kimura)
    watching = inner_notifications(:notification_watching)
    email = NotificationMailer.watching_notification(
      watch.watchable,
      watching.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ["info@fjord.jp"], email.from
    assert_equal ["kimura@fjord.jp"], email.to
    assert_equal "[bootcamp] あなたがウォッチしている【 作業週1日目 】にコメントが投稿されました。", email.subject
    assert_match %r{ウォッチ}, email.body.to_s
  end
end
