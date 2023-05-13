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
