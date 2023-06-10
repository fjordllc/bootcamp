# frozen_string_literal: true

require 'test_helper'

class ActivityMailerTest < ActionMailer::TestCase
  test 'graduated' do
    user = users(:sotugyou)
    mentor = users(:mentormentaro)
    ActivityMailer.graduated(
      sender: user,
      receiver: mentor
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 18, link: "/users/#{user.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] sotugyouさんが卒業しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">sotugyouさんのページへ</a>}, email.body.to_s)
  end

  test 'graduated with params' do
    user = users(:sotugyou)
    mentor = users(:mentormentaro)
    mailer = ActivityMailer.with(
      sender: user,
      receiver: mentor
    ).graduated

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 18, link: "/users/#{user.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] sotugyouさんが卒業しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">sotugyouさんのページへ</a>}, email.body.to_s)
  end

  test 'graduated with user who have been denied' do
    ActivityMailer.graduated(
      sender: users(:sotugyou),
      receiver: users(:hajime)
    ).deliver_now

    assert ActionMailer::Base.deliveries.empty?
  end

  test 'comebacked' do
    user = users(:kimura)
    mentor = users(:mentormentaro)
    ActivityMailer.comebacked(
      sender: user,
      receiver: mentor
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 23, link: "/users/#{user.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんが休会から復帰しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">kimuraさんのページへ</a>}, email.body.to_s)
  end

  test 'comebacked with params' do
    user = users(:kimura)
    mentor = users(:mentormentaro)
    mailer = ActivityMailer.with(
      sender: user,
      receiver: mentor
    ).comebacked

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 23, link: "/users/#{user.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんが休会から復帰しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">kimuraさんのページへ</a>}, email.body.to_s)
  end

  test 'comebacked with user who have been denied' do
    ActivityMailer.comebacked(
      sender: users(:kimura),
      receiver: users(:hajime)
    ).deliver_now

    assert ActionMailer::Base.deliveries.empty?
  end

  test 'came_answer' do
    answer = answers(:answer3)
    ActivityMailer.came_answer(answer: answer).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 4, link: "/questions/#{answer.question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんから回答がありました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">回答へ</a>}, email.body.to_s)
  end

  test 'came_answer with params' do
    answer = answers(:answer3)
    mailer = ActivityMailer.with(answer: answer).came_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 4, link: "/questions/#{answer.question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんから回答がありました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">回答へ</a>}, email.body.to_s)
  end

  test 'came_answer to mute email notification or retired user' do
    answer = answers(:answer3)
    receiver = users(:sotugyou)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'post_announcement' do
    announce = announcements(:announcement1)
    receiver = users(:sotugyou)
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver: receiver
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 5, link: "/announcements/#{announce.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] お知らせ「お知らせ1」', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">このお知らせへ</a>}, email.body.to_s)
  end

  test 'post_announcement with params' do
    announce = announcements(:announcement1)
    receiver = users(:sotugyou)
    mailer = ActivityMailer.with(
      announcement: announce,
      receiver: receiver
    ).post_announcement

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 5, link: "/announcements/#{announce.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] お知らせ「お知らせ1」', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">このお知らせへ</a>}, email.body.to_s)
  end

  test 'post_announcement to mute email notification or retired user' do
    announce = announcements(:announcement1)
    receiver = users(:sotugyou)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver: receiver
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver: receiver
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver: receiver
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver: receiver
    ).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'came_question' do
    question = questions(:question1)
    user = question.user
    mentor = users(:komagata)

    ActivityMailer.came_question(
      sender: user,
      receiver: mentor,
      question: question
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 6, link: "/questions/#{question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] machidaさんから質問「どのエディターを使うのが良いでしょうか」が投稿されました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">質問へ</a>}, email.body.to_s)
  end

  test 'came_question with params' do
    question = questions(:question1)
    user = question.user
    mentor = users(:komagata)

    mailer = ActivityMailer.with(
      sender: user,
      receiver: mentor,
      question: question
    ).came_question

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 6, link: "/questions/#{question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] machidaさんから質問「どのエディターを使うのが良いでしょうか」が投稿されました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">質問へ</a>}, email.body.to_s)
  end

  test 'mentioned' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)
    ActivityMailer.mentioned(
      mentionable: mentionable,
      receiver: mentioned.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 2, link: mentionable.path }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] sotugyouさんの日報「学習週1日目」へのコメントでkomagataさんからメンションがありました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">このメンションへ</a>}, email.body.to_s)
  end

  test 'mentioned with params' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)
    mailer = ActivityMailer.with(
      mentionable: mentionable,
      receiver: mentioned.user
    ).mentioned

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 2, link: mentionable.path }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] sotugyouさんの日報「学習週1日目」へのコメントでkomagataさんからメンションがありました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">このメンションへ</a>}, email.body.to_s)
  end

  test 'mentioned to mute email notification or retired user' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)

    mentioned.user.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable: mentionable,
      receiver: mentioned.user
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    mentioned.user.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable: mentionable,
      receiver: mentioned.user
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    mentioned.user.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable: mentionable,
      receiver: mentioned.user
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    mentioned.user.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable: mentionable,
      receiver: mentioned.user
    ).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'retired' do
    user = users(:yameo)
    mentor = users(:mentormentaro)
    ActivityMailer.retired(
      sender: user,
      receiver: mentor
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 9, link: "/users/#{user.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] yameoさんが退会しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">yameoさんのページへ</a>}, email.body.to_s)
  end

  test 'retired with params' do
    user = users(:yameo)
    mentor = users(:mentormentaro)
    mailer = ActivityMailer.with(
      sender: user,
      receiver: mentor
    ).retired

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 9, link: "/users/#{user.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] yameoさんが退会しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">yameoさんのページへ</a>}, email.body.to_s)
  end

  test 'retired with user who have been denied' do
    ActivityMailer.retired(
      sender: users(:yameo),
      receiver: users(:hajime)
    ).deliver_now

    assert ActionMailer::Base.deliveries.empty?
  end

  test 'checked' do
    check = checks(:procuct2_check_komagata)

    ActivityMailer.checked(
      sender: check.sender,
      receiver: check.receiver,
      check: check
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんの「OS X Mountain Lionをクリーンインストールする」の提出物を確認しました。', email.subject
    assert_match(/確認/, email.body.to_s)
  end

  test 'checked with params' do
    check = checks(:procuct2_check_komagata)

    mailer = ActivityMailer.with(
      sender: check.sender,
      receiver: check.receiver,
      check: check
    ).checked

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんの「OS X Mountain Lionをクリーンインストールする」の提出物を確認しました。', email.subject
    assert_match(/確認/, email.body.to_s)
  end

  test 'checked with user who have been denied' do
    check = checks(:procuct2_check_komagata)
    ActivityMailer.checked(
      sender: check.sender,
      receiver: users(:hajime),
      check: check
    ).deliver_now

    assert ActionMailer::Base.deliveries.empty?
  end

  test 'create_page' do
    page = pages(:page4)
    receiver = users(:mentormentaro)

    ActivityMailer.create_page(
      page: page,
      receiver: receiver
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 12, link: "/pages/#{page.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] komagataさんがDocsにBootcampの作業のページを投稿しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">このDocsへ</a>}, email.body.to_s)
  end

  test 'create_page with params' do
    page = pages(:page4)
    receiver = users(:mentormentaro)

    mailer = ActivityMailer.with(
      page: page,
      receiver: receiver
    ).create_page

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 12, link: "/pages/#{page.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] komagataさんがDocsにBootcampの作業のページを投稿しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">このDocsへ</a>}, email.body.to_s)
  end

  test 'moved_up_event_waiting_user' do
    event = events(:event3)
    notification = notifications(:notification_moved_up_event_waiting_user)
    ActivityMailer.moved_up_event_waiting_user(
      receiver: notification.user,
      event: event
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 11, link: "/events/#{event.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hatsuno@fjord.jp'], email.to
    assert_equal '[FBC] 募集期間中のイベント(補欠者あり)で、補欠から参加に繰り上がりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">特別イベント詳細へ</a>}, email.body.to_s)
  end

  test 'moved_up_event_waiting_user with params' do
    event = events(:event3)
    notification = notifications(:notification_moved_up_event_waiting_user)
    mailer = ActivityMailer.moved_up_event_waiting_user(
      receiver: notification.user,
      event: event
    )

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 11, link: "/events/#{event.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hatsuno@fjord.jp'], email.to
    assert_equal '[FBC] 募集期間中のイベント(補欠者あり)で、補欠から参加に繰り上がりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">特別イベント詳細へ</a>}, email.body.to_s)
  end

  test 'submitted' do
    product = products(:product11)
    receiver = users(:mentormentaro)

    ActivityMailer.submitted(
      receiver: receiver,
      product: product
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 3, link: "/products/#{product.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] hatsunoさんが「Terminalの基礎を覚える」の提出物を提出しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">提出物へ</a>}, email.body.to_s)
  end

  test 'submitted with params' do
    product = products(:product11)
    receiver = users(:mentormentaro)

    mailer = ActivityMailer.with(
      receiver: receiver,
      product: product
    ).submitted

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 3, link: "/products/#{product.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] hatsunoさんが「Terminalの基礎を覚える」の提出物を提出しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">提出物へ</a>}, email.body.to_s)
  end

  test 'submitted with user who have been denied' do
    product = products(:product11)
    receiver = users(:hajime)

    ActivityMailer.submitted(
      receiver: receiver,
      product: product
    ).deliver_now

    assert ActionMailer::Base.deliveries.empty?
  end

  test 'following_report' do
    report = reports(:report23)
    user = report.user
    receiver = users(:muryou)

    ActivityMailer.following_report(
      sender: user,
      receiver: receiver,
      report: report
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 13, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['muryou@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんが日報【 フォローされた日報 】を書きました！', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この日報へ</a>}, email.body.to_s)
  end

  test 'following_report with params' do
    report = reports(:report23)
    user = report.user
    receiver = users(:muryou)

    mailer = ActivityMailer.with(
      sender: user,
      receiver: receiver,
      report: report
    ).following_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 13, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['muryou@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんが日報【 フォローされた日報 】を書きました！', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この日報へ</a>}, email.body.to_s)
  end

  test 'watching_notification' do
    watch = watches(:report1_watch_kimura)
    watching = notifications(:notification_watching)
    mailer = ActivityMailer.with(
      watchable: watch.watchable,
      receiver: watching.user,
      comment: comments(:comment1),
      sender: comments(:comment1).user
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

  test 'assigned_as_checker' do
    product = products(:product64)
    receiver = User.find(product.checker_id)

    ActivityMailer.assigned_as_checker(
      product: product,
      receiver: receiver
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 16, link: "/products/#{product.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['machidanohimitsu@gmail.com'], email.to
    assert_equal '[FBC] kimuraさんの提出物「sshdをインストールする」の提出物の担当になりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この提出物へ</a>}, email.body.to_s)
  end

  test 'assigned_as_checker with params' do
    product = products(:product64)
    receiver = User.find(product.checker_id)

    mailer = ActivityMailer.with(
      product: product,
      receiver: receiver
    ).assigned_as_checker

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 16, link: "/products/#{product.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['machidanohimitsu@gmail.com'], email.to
    assert_equal '[FBC] kimuraさんの提出物「sshdをインストールする」の提出物の担当になりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この提出物へ</a>}, email.body.to_s)
  end

  test 'assigned_as_checker to mute email notification or retired user' do
    product = products(:product64)
    receiver = User.find(product.checker_id)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product: product,
      receiver: receiver
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product: product,
      receiver: receiver
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product: product,
      receiver: receiver
    ).deliver_now
    assert ActionMailer::Base.deliveries.empty?

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product: product,
      receiver: receiver
    ).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'hibernated using synchronous mailer' do
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
    ActivityMailer.hibernated(
      sender: user,
      receiver: mentor
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんが休会しました。', email.subject
    assert_match(/休会/, email.body.to_s)
  end

  test 'hibernated with params using asynchronous mailer' do
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
    mailer = ActivityMailer.with(
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

  test 'first_report using synchronous mailer' do
    report = reports(:report10)
    first_report = notifications(:notification_first_report)
    ActivityMailer.first_report(
      report: report,
      receiver: first_report.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんがはじめての日報を書きました！', email.subject
    assert_match(/はじめて/, email.body.to_s)
  end

  test 'first_report with params using asynchronous mailer' do
    report = reports(:report10)
    first_report = notifications(:notification_first_report)
    mailer = ActivityMailer.with(
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

  test 'consecutive_sad_report' do
    report = reports(:report16)
    consecutive_sad_report = notifications(:notification_consecutive_sad_report)
    ActivityMailer.consecutive_sad_report(
      report: report,
      receiver: consecutive_sad_report.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 15, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんが2回連続でsadアイコンの日報を提出しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この日報へ</a>}, email.body.to_s)
  end

  test 'consecutive_sad_report with params' do
    report = reports(:report16)
    consecutive_sad_report = notifications(:notification_consecutive_sad_report)
    mailer = ActivityMailer.with(
      report: report,
      receiver: consecutive_sad_report.user
    ).consecutive_sad_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 15, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんが2回連続でsadアイコンの日報を提出しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この日報へ</a>}, email.body.to_s)
  end
end
