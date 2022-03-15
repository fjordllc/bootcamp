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
    assert_equal '[bootcamp] komagataさんからコメントが届きました。', email.subject
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
    assert_equal '[bootcamp] sotugyouさんの学習週1日目を確認しました。', email.subject
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
    assert_equal '[bootcamp] sotugyouさんの日報「学習週1日目」へのコメントでkomagataさんからメンションがありました。', email.subject
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
    assert_equal "[bootcamp] sotugyouさんが「#{product.title}」を提出しました。", email.subject
    assert_match(/提出/, email.body.to_s)
  end

  test 'came_answer' do
    answer = answers(:answer3)
    mailer = NotificationMailer.with(answer: answer).came_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[bootcamp] komagataさんから回答がありました。', email.subject
    assert_match(/回答/, email.body.to_s)
  end

  test 'post_announcement' do
    announce = announcements(:announcement1)
    announced = notifications(:notification_announced)
    mailer = NotificationMailer.with(
      announcement: announce,
      receiver: announced.user
    ).post_announcement

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[bootcamp] お知らせ「お知らせ1」', email.subject
    assert_match(/お知らせ/, email.body.to_s)
  end

  test 'came_question' do
    question = questions(:question2)
    questioned = notifications(:notification_questioned)
    mailer = NotificationMailer.with(
      question: question,
      receiver: questioned.user
    ).came_question

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[bootcamp] sotugyouさんから質問「injectとreduce」が投稿されました。', email.subject
    assert_match(/質問/, email.body.to_s)
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
    assert_equal '[bootcamp] hajimeさんがはじめての日報を書きました！', email.subject
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
    assert_equal '[bootcamp] komagataさんがDocsにBootcampの作業のページを投稿しました。', email.subject
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
    assert_equal '[bootcamp] komagataさんの【 「作業週1日目」の日報 】にmachidaさんがコメントしました。', email.subject
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
    assert_equal '[bootcamp] yameoさんが退会しました。', email.subject
    assert_match(/退会/, email.body.to_s)
  end

  test 'three_months_after_retirement' do
    user = users(:kensyuowata)
    admin = users(:komagata)
    mailer = NotificationMailer.with(
      sender: user,
      receiver: admin
    ).three_months_after_retirement

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[bootcamp] kensyuowataさんが退会してから3カ月が経過しました。', email.subject
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
    assert_equal '[bootcamp] kensyuさんが日報【 研修の日報 】を書きました！', email.subject
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
    assert_equal '[bootcamp] 募集期間中のイベント(補欠者あり)で、補欠から参加に繰り上がりました。', email.subject
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
    assert_equal '[bootcamp] kensyuさんが日報【 フォローされた日報 】を書きました！', email.subject
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
    assert_equal '[bootcamp] hajimeさんの質問【 解決済みの質問 】でadvijirouさんの回答がベストアンサーに選ばれました。', email.subject
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
    assert_equal '[bootcamp] hajimeさんが2回連続でsadアイコンの日報を提出しました。', email.subject
    assert_match(/2回連続/, email.body.to_s)
  end
end
