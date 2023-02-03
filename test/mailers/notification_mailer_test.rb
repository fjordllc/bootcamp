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

  test 'checked' do
    check = checks(:report5_check_machida)
    mailer = NotificationMailer.with(check: check).checked

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] sotugyouさんの学習週1日目を確認しました。', email.subject
    assert_match(/確認/, email.body.to_s)
  end

  test 'mentioned' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)
    mailer = NotificationMailer.with(
      mentionable: mentionable,
      receiver: mentioned.user
    ).mentioned

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] sotugyouさんの日報「学習週1日目」へのコメントでkomagataさんからメンションがありました。', email.subject
    assert_match(/メンション/, email.body.to_s)
  end

  test 'submitted' do
    product = products(:product3)
    submitted = notifications(:notification_submitted)
    mailer = NotificationMailer.with(
      product: product,
      receiver: submitted.user,
      message: "#{product.user.login_name}さんが「#{product.title}」を提出しました。"
    ).submitted

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal "[FBC] sotugyouさんが「#{product.title}」を提出しました。", email.subject
    assert_match(/提出/, email.body.to_s)
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

  test 'create_page' do
    page = pages(:page4)
    create_page = notifications(:notification_create_page)
    mailer = NotificationMailer.with(
      page: page,
      receiver: create_page.user
    ).create_page

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hatsuno@fjord.jp'], email.to
    assert_equal '[FBC] komagataさんがDocsにBootcampの作業のページを投稿しました。', email.subject
    assert_match(/Bootcamp/, email.body.to_s)
  end

  test 'watching_notification' do
    watch = watches(:report1_watch_kimura)
    watching = notifications(:notification_watching)
    mailer = NotificationMailer.with(
      watchable: watch.watchable,
      receiver: watching.user,
      comment: comments(:comment1)
    ).watching_notification

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] komagataさんの【 「作業週1日目」の日報 】にmachidaさんがコメントしました。', email.subject
    assert_match(/コメント/, email.body.to_s)
  end

  test 'retired' do
    user = users(:yameo)
    admin = users(:komagata)
    mailer = NotificationMailer.with(
      sender: user,
      receiver: admin
    ).retired

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] yameoさんが退会しました。', email.subject
    assert_match(/退会/, email.body.to_s)
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

  test 'moved_up_event_waiting_user' do
    event = events(:event3)
    notification = notifications(:notification_moved_up_event_waiting_user)
    mailer = NotificationMailer.with(
      event: event,
      receiver: notification.user
    ).moved_up_event_waiting_user

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hajime@fjord.jp'], email.to
    assert_equal '[FBC] 募集期間中のイベント(補欠者あり)で、補欠から参加に繰り上がりました。', email.subject
    assert_match(/イベント/, email.body.to_s)
  end

  test 'following_report' do
    report = reports(:report23)
    notification = notifications(:notification_following_report)
    mailer = NotificationMailer.with(
      report: report,
      receiver: notification.user
    ).following_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['muryou@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんが日報【 フォローされた日報 】を書きました！', email.subject
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

  test 'hibernated' do
    user = users(:kimura)
    mentor = users(:komagata)
    Notification.create!(
      kind: 19,
      sender: user,
      user: mentor,
      message: 'kimuraさんが休会しました。',
      link: "/users/#{user.id}",
      read: false
    )
    mailer = NotificationMailer.with(
      sender: user,
      receiver: mentor
    ).hibernated

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんが休会しました。', email.subject
    assert_match(/休会/, email.body.to_s)
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
