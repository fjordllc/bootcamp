# frozen_string_literal: true

require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  test 'came_comment' do
    comment = comments(:comment9)
    came_comment = notifications(:notification_commented)
    mailer = NotificationMailer.with(
      comment: comment,
      receiver: came_comment.user,
      message: "#{comment.user.login_name}さんからコメントが届きました。"
    ).came_comment

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんからコメントが届きました。', email.subject
    assert_match(/コメント/, email.body.to_s)
  end

  test 'first_report' do
    report = reports(:report10)
    first_report = notifications(:notification_first_report)
    mailer = NotificationMailer.with(
      report: report,
      receiver: first_report.user
    ).first_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんがはじめての日報を書きました！', email.subject
    assert_match(/はじめて/, email.body.to_s)
  end

  test 'trainee_report' do
    report = reports(:report11)
    trainee_report = notifications(:notification_trainee_report)
    mailer = NotificationMailer.with(
      report: report,
      receiver: trainee_report.user
    ).trainee_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['senpai@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんが日報【 研修の日報 】を書きました！', email.subject
    assert_match(/日報/, email.body.to_s)
  end

  test 'chose_correct_answer' do
    answer = correct_answers(:correct_answer2)
    notification = notifications(:notification_chose_correct_answer)
    mailer = NotificationMailer.with(
      answer: answer,
      receiver: notification.user
    ).chose_correct_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['advijirou@example.com'], email.to
    assert_equal '[FBC] hajimeさんの質問【 解決済みの質問 】でadvijirouさんの回答がベストアンサーに選ばれました。', email.subject
    assert_match(/回答/, email.body.to_s)
  end

  test 'consecutive_sad_report' do
    report = reports(:report16)
    consecutive_sad_report = notifications(:notification_consecutive_sad_report)
    mailer = NotificationMailer.with(
      report: report,
      receiver: consecutive_sad_report.user
    ).consecutive_sad_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんが2回連続でsadアイコンの日報を提出しました。', email.subject
    assert_match(/2回連続/, email.body.to_s)
  end

  test 'signed up' do
    user = users(:hajime)
    mentor = users(:mentormentaro)
    Notification.create!(
      kind: 20,
      sender: user,
      user: mentor,
      message: '🎉 hajimeさんが新しく入会しました！',
      link: "/users/#{user.id}",
      read: false
    )
    mailer = NotificationMailer.with(
      sender: user,
      receiver: mentor
    ).signed_up

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんが新しく入会しました！', email.subject
    assert_match(/入会/, email.body.to_s)
  end

  test 'update_regular_event' do
    regular_event = regular_events(:regular_event1)
    notification = notifications(:notification_regular_event_updated)
    mailer = NotificationMailer.with(
      regular_event: regular_event,
      receiver: notification.user
    ).update_regular_event

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hatsuno@fjord.jp'], email.to
    assert_equal '[FBC] 定期イベント【開発MTG】が更新されました。', email.subject
    assert_match(/定期イベント/, email.body.to_s)
  end

  test 'no_correct_answer' do
    user = users(:kimura)
    question = questions(:question8)
    Notification.create!(
      kind: 22,
      sender: user,
      user: user,
      message: 'Q&A「テストの質問」のベストアンサーがまだ選ばれていません。',
      link: "/questions/#{question.id}",
      read: false
    )
    mailer = NotificationMailer.with(
      question: question,
      receiver: user
    ).no_correct_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんの質問【 テストの質問 】のベストアンサーがまだ選ばれていません。', email.subject
    assert_match(/まだ選ばれていません/, email.body.to_s)
  end
end
