# frozen_string_literal: true

require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "came_comment" do
    comment = comments(:comment_9)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんからコメントが届きました。", email.subject
    assert_match %r{コメント}, email.body.to_s
  end

  test "checked" do
    check = checks(:report5_check_machida)
    mailer = NotificationMailer.with(check: check).checked

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] sotugyouさんの学習週1日目を確認しました。", email.subject
    assert_match %r{確認}, email.body.to_s
  end

  test "mentioned" do
    mentionable = comments(:comment_9)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] sotugyouさんの日報「学習週1日目」へのコメントでkomagataさんからメンションがありました。", email.subject
    assert_match %r{メンション}, email.body.to_s
  end

  test "submitted" do
    product = products(:product_3)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] sotugyouさんが「#{product.title}」を提出しました。", email.subject
    assert_match %r{提出}, email.body.to_s
  end

  test "came_answer" do
    answer = answers(:answer_3)
    mailer = NotificationMailer.with(answer: answer).came_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんから回答がありました。", email.subject
    assert_match %r{回答}, email.body.to_s
  end

  test "post_announcement" do
    announce = announcements(:announcement_1)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["sotugyou@example.com"], email.to
    assert_equal "[bootcamp] komagataさんからお知らせです。", email.subject
    assert_match %r{お知らせ}, email.body.to_s
  end

  test "came_question" do
    question = questions(:question_2)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] sotugyouさんから質問がありました。", email.subject
    assert_match %r{質問}, email.body.to_s
  end

  test "first_report" do
    report = reports(:report_10)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] hajimeさんがはじめての日報を書きました！", email.subject
    assert_match %r{はじめて}, email.body.to_s
  end

  test "create_page" do
    page = pages(:page_4)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["hatsuno@fjord.jp"], email.to
    assert_equal "[bootcamp] komagataさんがDocsにBootcampの作業のページを投稿しました。", email.subject
    assert_match %r{Bootcamp}, email.body.to_s
  end

  test "watching_notification" do
    watch = watches(:report1_watch_kimura)
    watching = notifications(:notification_watching)
    mailer = NotificationMailer.with(
      watchable: watch.watchable,
      receiver: watching.user,
      comment: comments(:comment_1)
    ).watching_notification

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["kimura@fjord.jp"], email.to
    assert_equal "[bootcamp] komagataさんの【 「作業週1日目」の日報 】にmachidaさんがコメントしました。", email.subject
  end

  test "retired" do
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["komagata@fjord.jp"], email.to
    assert_equal "[bootcamp] yameoさんが退会しました。", email.subject
    assert_match %r{退会}, email.body.to_s
  end

  test "trainee_report" do
    report = reports(:report_11)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["senpai@fjord.jp"], email.to
    assert_equal "[bootcamp] kensyuさんが日報【 研修の日報 】を書きました！", email.subject
    assert_match %r{日報}, email.body.to_s
  end

  test "moved_up_event_waiting_user" do
    event = events(:event_3)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["hajime@fjord.jp"], email.to
    assert_equal "[bootcamp] 募集期間中のイベント(補欠者あり)で、補欠から参加に繰り上がりました。", email.subject
    assert_match %r{イベント}, email.body.to_s
  end

  test "following_report" do
    report = reports(:report_23)
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
    assert_equal ["noreply@bootcamp.fjord.jp"], email.from
    assert_equal ["muryou@fjord.jp"], email.to
    assert_equal "[bootcamp] kensyuさんが日報【 フォローされた日報 】を書きました！", email.subject
    assert_match %r{日報}, email.body.to_s
  end
end
