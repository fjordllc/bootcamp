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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">sotugyouさんのページへ</a>}, email.body.to_s)
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">sotugyouさんのページへ</a>}, email.body.to_s)
  end

  test 'graduated with user who have been denied' do
    ActivityMailer.graduated(
      sender: users(:sotugyou),
      receiver: users(:hajime)
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">kimuraさんのページへ</a>}, email.body.to_s)
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">kimuraさんのページへ</a>}, email.body.to_s)
  end

  test 'comebacked with user who have been denied' do
    ActivityMailer.comebacked(
      sender: users(:kimura),
      receiver: users(:hajime)
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'came_answer' do
    answer = answers(:answer3)
    ActivityMailer.came_answer(answer:).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 4, link: "/questions/#{answer.question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんから回答がありました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">回答へ</a>}, email.body.to_s)
  end

  test 'came_answer with params' do
    answer = answers(:answer3)
    mailer = ActivityMailer.with(answer:).came_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 4, link: "/questions/#{answer.question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんから回答がありました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">回答へ</a>}, email.body.to_s)
  end

  test 'came_answer to mute email notification or retired user' do
    answer = answers(:answer3)
    receiver = users(:sotugyou)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.came_answer(answer: answer.reload).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'post_announcement' do
    announce = announcements(:announcement1)
    receiver = users(:sotugyou)
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 5, link: "/announcements/#{announce.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] お知らせ「お知らせ1」', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">このお知らせへ</a>}, email.body.to_s)
  end

  test 'post_announcement with params' do
    announce = announcements(:announcement1)
    receiver = users(:sotugyou)
    mailer = ActivityMailer.with(
      announcement: announce,
      receiver:
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">このお知らせへ</a>}, email.body.to_s)
    assert_match(/<a .+ href="#{Regexp.escape(full_url_for("/users/#{announce.user.id}"))}">/, email.body.to_s)
  end

  test 'post_announcement to mute email notification or retired user' do
    announce = announcements(:announcement1)
    receiver = users(:sotugyou)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver:
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver:
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver:
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.post_announcement(
      announcement: announce,
      receiver:
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
      question:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 6, link: "/questions/#{question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] machidaさんから質問「どのエディターを使うのが良いでしょうか」が投稿されました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">質問へ</a>}, email.body.to_s)
  end

  test 'came_question with params' do
    question = questions(:question1)
    user = question.user
    mentor = users(:komagata)

    mailer = ActivityMailer.with(
      sender: user,
      receiver: mentor,
      question:
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">質問へ</a>}, email.body.to_s)
  end

  test 'came_question with no practice' do
    question = questions(:question14)
    user = question.user
    mentor = users(:komagata)

    ActivityMailer.came_question(
      sender: user,
      receiver: mentor,
      question:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 6, link: "/questions/#{question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんから質問「プラクティスを選択せずに登録したテストの質問」が投稿されました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">質問へ</a>}, email.body.to_s)
  end

  test 'mentioned' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)
    ActivityMailer.mentioned(
      mentionable:,
      receiver: mentioned.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 2, link: mentionable.path }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] sotugyouさんの日報「学習週1日目」へのコメントでkomagataさんからメンションがありました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">このメンションへ</a>}, email.body.to_s)
  end

  test 'mentioned with params' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)
    mailer = ActivityMailer.with(
      mentionable:,
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">このメンションへ</a>}, email.body.to_s)
  end

  test 'mentioned to mute email notification or retired user' do
    mentionable = comments(:comment9)
    mentioned = notifications(:notification_mentioned)

    mentioned.user.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable:,
      receiver: mentioned.user
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    mentioned.user.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable:,
      receiver: mentioned.user
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    mentioned.user.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable:,
      receiver: mentioned.user
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    mentioned.user.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.mentioned(
      mentionable:,
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">yameoさんのページへ</a>}, email.body.to_s)
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">yameoさんのページへ</a>}, email.body.to_s)
  end

  test 'retired with user who have been denied' do
    ActivityMailer.retired(
      sender: users(:yameo),
      receiver: users(:hajime)
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'checked' do
    check = checks(:procuct2_check_komagata)

    ActivityMailer.checked(
      sender: check.sender,
      receiver: check.receiver,
      check:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんの「OS X Mountain Lionをクリーンインストールする」の提出物を合格にしました。', email.subject
    assert_match(/合格/, email.body.to_s)
  end

  test 'trainee and advisers receive different wording in their acceptance emails' do
    check = checks(:procuct75_check_komagata)

    ActivityMailer.checked(
      sender: check.sender,
      receiver: check.receiver,
      check:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kensyu@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんの「aptの基礎を覚える」の提出物を合格にしました。', email.subject
    assert_match(/「aptの基礎を覚える」の提出物/, email.body.to_s)
    assert_no_match(/kensyuさんの「aptの基礎を覚える」の提出物/, email.body.to_s)
    assert_match(/合格/, email.body.to_s)

    assert_includes(check.receiver.company.advisers, users(:senpai))

    ActivityMailer.checked(
      sender: check.sender,
      receiver: users(:senpai),
      check:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['senpai@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんの「aptの基礎を覚える」の提出物を合格にしました。', email.subject
    assert_match(/kensyuさんの「aptの基礎を覚える」の提出物/, email.body.to_s)
    assert_match(/合格/, email.body.to_s)
  end

  test 'checked with params' do
    check = checks(:procuct2_check_komagata)

    mailer = ActivityMailer.with(
      sender: check.sender,
      receiver: check.receiver,
      check:
    ).checked

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんの「OS X Mountain Lionをクリーンインストールする」の提出物を合格にしました。', email.subject
    assert_match(/合格/, email.body.to_s)
  end

  test 'checked with user who have been denied' do
    check = checks(:procuct2_check_komagata)
    ActivityMailer.checked(
      sender: check.sender,
      receiver: users(:hajime),
      check:
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'create_page' do
    page = pages(:page4)
    receiver = users(:mentormentaro)

    ActivityMailer.create_page(
      page:,
      receiver:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 12, link: "/pages/#{page.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] komagataさんがDocsにBootcampの作業のページを投稿しました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">このDocsへ</a>}, email.body.to_s)
  end

  test 'create_page with params' do
    page = pages(:page4)
    receiver = users(:mentormentaro)

    mailer = ActivityMailer.with(
      page:,
      receiver:
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">このDocsへ</a>}, email.body.to_s)
  end

  test 'moved_up_event_waiting_user' do
    event = events(:event3)
    notification = notifications(:notification_moved_up_event_waiting_user)
    ActivityMailer.moved_up_event_waiting_user(
      receiver: notification.user,
      event:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 11, link: "/events/#{event.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hatsuno@fjord.jp'], email.to
    assert_equal '[FBC] 募集期間中のイベント(補欠者あり)で、補欠から参加に繰り上がりました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">特別イベント詳細へ</a>}, email.body.to_s)
  end

  test 'moved_up_event_waiting_user with params' do
    event = events(:event3)
    notification = notifications(:notification_moved_up_event_waiting_user)
    mailer = ActivityMailer.moved_up_event_waiting_user(
      receiver: notification.user,
      event:
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">特別イベント詳細へ</a>}, email.body.to_s)
  end

  test 'submitted' do
    product = products(:product11)
    receiver = users(:mentormentaro)

    ActivityMailer.submitted(
      receiver:,
      product:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] hatsunoさんが「Terminalの基礎を覚える」の提出物を提出しました。', email.subject
    expected = Regexp.escape(Rails.application.routes.url_helpers.notification_redirector_url(link: "/products/#{product.id}", kind: 3).gsub('&', '&amp;'))
    assert_match(%r{<a .+ href="#{expected}">提出物へ</a>}, email.body.to_s)
  end

  test 'submitted with params' do
    product = products(:product11)
    receiver = users(:mentormentaro)

    mailer = ActivityMailer.with(
      receiver:,
      product:
    ).submitted

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] hatsunoさんが「Terminalの基礎を覚える」の提出物を提出しました。', email.subject
    expected = Regexp.escape(Rails.application.routes.url_helpers.notification_redirector_url(link: "/products/#{product.id}", kind: 3).gsub('&', '&amp;'))
    assert_match(%r{<a .+ href="#{expected}">提出物へ</a>}, email.body.to_s)
  end

  test 'submitted with user who have been denied' do
    product = products(:product11)
    receiver = users(:hajime)

    ActivityMailer.submitted(
      receiver:,
      product:
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'following_report' do
    report = reports(:report23)
    user = report.user
    receiver = users(:muryou)

    ActivityMailer.following_report(
      sender: user,
      receiver:,
      report:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 13, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['muryou@fjord.jp'], email.to
    assert_equal '[FBC] kensyuさんが日報【 フォローされた日報 】を書きました！', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">この日報へ</a>}, email.body.to_s)
  end

  test 'following_report with params' do
    report = reports(:report23)
    user = report.user
    receiver = users(:muryou)

    mailer = ActivityMailer.with(
      sender: user,
      receiver:,
      report:
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">この日報へ</a>}, email.body.to_s)
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
    assert_equal '[FBC] komagataさんの日報「作業週1日目」にmachidaさんがコメントしました。', email.subject
    assert_match(/コメント/, email.body.to_s)
  end

  test 'assigned_as_checker' do
    product = products(:product64)
    receiver = User.find(product.checker_id)

    ActivityMailer.assigned_as_checker(
      product:,
      receiver:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 16, link: "/products/#{product.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['machidanohimitsu@gmail.com'], email.to
    assert_equal '[FBC] kimuraさんの提出物「sshdをインストールする」の提出物の担当になりました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">この提出物へ</a>}, email.body.to_s)
  end

  test 'assigned_as_checker with params' do
    product = products(:product64)
    receiver = User.find(product.checker_id)

    mailer = ActivityMailer.with(
      product:,
      receiver:
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
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">この提出物へ</a>}, email.body.to_s)
  end

  test 'assigned_as_checker to mute email notification or retired user' do
    product = products(:product64)
    receiver = User.find(product.checker_id)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product:,
      receiver:
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product:,
      receiver:
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product:,
      receiver:
    ).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.assigned_as_checker(
      product:,
      receiver:
    ).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'hibernated using synchronous mailer' do
    user = users(:kyuukai)
    mentor = users(:komagata)
    Notification.create!(
      kind: 19,
      sender: user,
      user: mentor,
      message: 'kyuukaiさんが休会しました。',
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
    assert_equal '[FBC] kyuukaiさんが休会しました。', email.subject
    assert_match(/休会/, email.body.to_s)
  end

  test 'hibernated with params using asynchronous mailer' do
    user = users(:kyuukai)
    mentor = users(:komagata)
    Notification.create!(
      kind: 19,
      sender: user,
      user: mentor,
      message: 'kyuukaiさんが休会しました。',
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
    assert_equal '[FBC] kyuukaiさんが休会しました。', email.subject
    assert_match(/休会/, email.body.to_s)
  end

  test 'first_report using synchronous mailer' do
    report = reports(:report10)
    first_report = notifications(:notification_first_report)
    ActivityMailer.first_report(
      report:,
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
      report:,
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

  test 'consecutive_negative_report' do
    report = reports(:report16)
    consecutive_negative_report = notifications(:notification_consecutive_negative_report)
    ActivityMailer.consecutive_negative_report(
      report:,
      receiver: consecutive_negative_report.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 15, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんが2回連続でnegativeアイコンの日報を提出しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この日報へ</a>}, email.body.to_s)
  end

  test 'consecutive_negative_report with params' do
    report = reports(:report16)
    consecutive_negative_report = notifications(:notification_consecutive_negative_report)
    mailer = ActivityMailer.with(
      report:,
      receiver: consecutive_negative_report.user
    ).consecutive_negative_report

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 15, link: "/reports/#{report.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんが2回連続でnegativeアイコンの日報を提出しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">この日報へ</a>}, email.body.to_s)
  end

  test 'update_regular_event using synchronous mailer' do
    regular_event = regular_events(:regular_event1)
    notification = notifications(:notification_regular_event_updated)

    ActivityMailer.update_regular_event(
      regular_event:,
      receiver: notification.user
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['hatsuno@fjord.jp'], email.to
    assert_equal '[FBC] 定期イベント【開発MTG】が更新されました。', email.subject
    assert_match(/定期イベント/, email.body.to_s)
  end

  test 'update_regular_event with params using asynchronous mailer' do
    regular_event = regular_events(:regular_event1)
    notification = notifications(:notification_regular_event_updated)

    mailer = ActivityMailer.with(
      regular_event:,
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

  test 'signed_up using synchronous mailer' do
    user = users(:hajime)
    mentor = users(:komagata)
    Notification.create!(
      kind: 20,
      sender: user,
      user: mentor,
      message: '🎉 hajimeさんが新しく入会しました！',
      link: "/users/#{user.id}",
      read: false
    )

    ActivityMailer.signed_up(
      sender: user,
      receiver: mentor
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんがRailsエンジニアコースに入会しました！', email.subject
    assert_match(/入会/, email.body.to_s)
  end

  test 'signed_up with params using asynchronous mailer' do
    user = users(:hajime)
    mentor = users(:komagata)
    Notification.create!(
      kind: 20,
      sender: user,
      user: mentor,
      message: '🎉 hajimeさんが新しく入会しました！',
      link: "/users/#{user.id}",
      read: false
    )
    mailer = ActivityMailer.with(
      sender: user,
      receiver: mentor
    ).signed_up

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] hajimeさんがRailsエンジニアコースに入会しました！', email.subject
    assert_match(/入会/, email.body.to_s)
  end

  test 'mentor receives email when user joins frontend engineer course' do
    user = User.create!(
      login_name: 'frontend',
      email: 'frontend@fjord.jp',
      password: 'testtest',
      name: 'フロント 極め太郎',
      name_kana: 'フロント キワメタロウ',
      description: 'フロントエンドエンジニアコースに入会したユーザーです',
      course: courses(:course4),
      job: 'unemployed',
      os: 'mac',
      experiences: 2
    )
    mentor = users(:komagata)

    ActivityMailer.signed_up(
      sender: user,
      receiver: mentor
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] frontendさんがフロントエンドエンジニアコースに入会しました！', email.subject
    assert_match(/入会/, email.body.to_s)
  end

  test 'chose_correct_answer with using synchronous mailer' do
    answer = correct_answers(:correct_answer1)
    receiver = answer.user

    ActivityMailer.chose_correct_answer(
      answer:,
      receiver:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: Notification.kinds[:chose_correct_answer], link: "/questions/#{answer.question.id}#answer_#{answer.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal [receiver.email], email.to
    assert_equal "[FBC] #{answer.receiver.login_name}さんの質問【 #{answer.question.title} 】で#{answer.sender.login_name}さんの回答がベストアンサーに選ばれました。", email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">回答へ</a>}, email.body.to_s)
  end

  test 'chose_correct_answer with params using asynchronous mailer' do
    answer = correct_answers(:correct_answer1)
    receiver = answer.user

    mailer = ActivityMailer.with(
      answer:,
      receiver:
    ).chose_correct_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: Notification.kinds[:chose_correct_answer], link: "/questions/#{answer.question.id}#answer_#{answer.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal [receiver.email], email.to
    assert_equal "[FBC] #{answer.receiver.login_name}さんの質問【 #{answer.question.title} 】で#{answer.sender.login_name}さんの回答がベストアンサーに選ばれました。", email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">回答へ</a>}, email.body.to_s)
  end

  test 'not send chose_correct_answer email to user with mail_notification off' do
    answer = correct_answers(:correct_answer1)
    receiver = answer.user
    receiver.update(mail_notification: false)

    mailer = ActivityMailer.with(
      answer:,
      receiver:
    ).chose_correct_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_empty ActionMailer::Base.deliveries
  end

  test 'not send chose_correct_answer email to retired user' do
    answer = correct_answers(:correct_answer1)
    receiver = answer.user
    receiver.update(retired_on: Date.current)

    mailer = ActivityMailer.with(
      answer:,
      receiver:
    ).chose_correct_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_empty ActionMailer::Base.deliveries
  end

  test 'no_correct_answer using synchronous mailer' do
    question = questions(:question1)
    receiver = question.user

    ActivityMailer.no_correct_answer(question:, receiver:).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: Notification.kinds[:no_correct_answer], link: "/questions/#{question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal [receiver.email], email.to
    assert_equal "[FBC] #{receiver.login_name}さんの質問【 #{question.title} 】のベストアンサーがまだ選ばれていません。", email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">#{receiver.login_name}さんの質問へ</a>}, email.body.to_s)
  end

  test 'no_correct_answer with params using asynchronous mailer' do
    question = questions(:question1)
    receiver = question.user

    mailer = ActivityMailer.with(question:, receiver:).no_correct_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: Notification.kinds[:no_correct_answer], link: "/questions/#{question.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal [receiver.email], email.to
    assert_equal "[FBC] #{receiver.login_name}さんの質問【 #{question.title} 】のベストアンサーがまだ選ばれていません。", email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">#{receiver.login_name}さんの質問へ</a>}, email.body.to_s)
  end

  test 'product_update' do
    product = products(:product1)
    receiver = users(:komagata)

    ActivityMailer.product_update(
      product:,
      receiver:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 17, link: "/products/#{product.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] mentormentaroさんが「OS X Mountain Lionをクリーンインストールする」の提出物を更新しました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">提出物へ</a>}, email.body.to_s)
  end

  test 'came_comment' do
    comment = comments(:commentOfTalk)
    commentable_path = Rails.application.routes.url_helpers.polymorphic_path(comment.commentable)

    Notification.create!(
      kind: Notification.kinds['came_comment'],
      user: comment.receiver,
      sender: comment.sender,
      link: "#{commentable_path}#latest-comment",
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      read: false
    )

    ActivityMailer.came_comment(
      comment:,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      receiver: comment.receiver
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] 相談部屋でkomagataさんからコメントがありました。', email.subject
    assert_match(/コメント/, email.body.to_s)
  end

  test 'came_comment with params' do
    comment = comments(:commentOfTalk)
    commentable_path = Rails.application.routes.url_helpers.polymorphic_path(comment.commentable)

    Notification.create!(
      kind: Notification.kinds['came_comment'],
      user: comment.receiver,
      sender: comment.sender,
      link: "#{commentable_path}#latest-comment",
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      read: false
    )

    mailer = ActivityMailer.with(
      comment:,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      receiver: comment.receiver
    ).came_comment

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] 相談部屋でkomagataさんからコメントがありました。', email.subject
    assert_match(/コメント/, email.body.to_s)
  end

  test 'came_comment for admin with mail_notification off' do
    admin = users(:komagata)
    admin.update(mail_notification: false)

    comment = comments(:commentOfTalk)

    ActivityMailer.came_comment(
      comment:,
      message: "相談部屋で#{comment.sender.login_name}さんからコメントがありました。",
      receiver: comment.receiver
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'create_article notifies students, trainees, mentors, and admins' do
    target_users = %i[hatsuno kensyu mentormentaro machida]

    target_users.each do |target_user|
      article = articles(:article1)
      receiver = users(target_user)

      ActivityMailer.create_article(
        article:,
        receiver:
      ).deliver_now

      assert_not ActionMailer::Base.deliveries.empty?
      email = ActionMailer::Base.deliveries.last
      query = CGI.escapeHTML({ kind: 24, link: "/articles/#{article.id}" }.to_param)
      assert_equal ['noreply@bootcamp.fjord.jp'], email.from
      assert_equal [receiver.email], email.to
      assert_equal "新しいブログ「#{article.title}」を#{article.user.login_name}さんが投稿しました！", email.subject
      assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">ブログへ</a>}, email.body.to_s)
    end
  end

  test 'create_article notifies students, trainees, mentors, and admins with params' do
    target_users = %i[hatsuno kensyu mentormentaro machida]

    target_users.each do |target_user|
      article = articles(:article1)
      receiver = users(target_user)

      mailer = ActivityMailer.with(
        article:,
        receiver:
      ).create_article

      perform_enqueued_jobs do
        mailer.deliver_later
      end

      assert_not ActionMailer::Base.deliveries.empty?
      email = ActionMailer::Base.deliveries.last
      query = CGI.escapeHTML({ kind: 24, link: "/articles/#{article.id}" }.to_param)
      assert_equal ['noreply@bootcamp.fjord.jp'], email.from
      assert_equal [receiver.email], email.to
      assert_equal "新しいブログ「#{article.title}」を#{article.user.login_name}さんが投稿しました！", email.subject
      assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">ブログへ</a>}, email.body.to_s)
    end
  end

  test 'create_article notifies students, trainees, mentors, and admins with mail_notification off' do
    article = articles(:article1)
    receiver = users(:mentormentaro)
    receiver.update(mail_notification: false)

    ActivityMailer.create_article(
      sender: article.user,
      receiver:,
      article:
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'added_work' do
    work = works(:work1)
    user = work.user
    receiver = users(:komagata)

    ActivityMailer.added_work(
      sender: user,
      receiver:,
      work:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 25, link: "/works/#{work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal "[FBC] kimuraさんがポートフォリオに作品「kimura\'s app」を追加しました。", email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">この作品へ</a>}, email.body.to_s)
  end

  test 'added_work with params' do
    work = works(:work1)
    user = work.user
    receiver = users(:komagata)

    mailer = ActivityMailer.with(
      sender: user,
      receiver:,
      work:
    ).added_work

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 25, link: "/works/#{work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんがポートフォリオに作品「kimura\'s app」を追加しました。', email.subject
    assert_match(%r{<a .+ href="#{expected_redirector_href(query)}">この作品へ</a>}, email.body.to_s)
  end

  test 'added_work for admin with mail_notification off' do
    work = works(:work1)
    user = work.user
    receiver = users(:komagata)
    receiver.update(mail_notification: false)

    ActivityMailer.added_work(
      sender: user,
      receiver:,
      work:
    ).deliver_now

    assert_empty ActionMailer::Base.deliveries
  end

  test 'came_pair_work' do
    pair_work = pair_works(:pair_work1)
    mentor = users(:komagata)

    ActivityMailer.came_pair_work(
      receiver: mentor,
      pair_work:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 28, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんからペアワーク依頼「募集中のペアワークです(タイトル)」が投稿されました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'came_pair_work with params' do
    pair_work = pair_works(:pair_work1)
    mentor = users(:komagata)

    mailer = ActivityMailer.with(
      receiver: mentor,
      pair_work:
    ).came_pair_work

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 28, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんからペアワーク依頼「募集中のペアワークです(タイトル)」が投稿されました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'matching_pair_work' do
    pair_work = pair_works(:pair_work2)
    mentor = users(:komagata)

    ActivityMailer.matching_pair_work(
      receiver: mentor,
      pair_work:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 29, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんのペアワーク【 ペア確定済みのペアワークです(タイトル) 】のペアがsotugyouさんに決定しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'matching_pair_work with params' do
    pair_work = pair_works(:pair_work2)
    mentor = users(:komagata)

    mailer = ActivityMailer.with(
      receiver: mentor,
      pair_work:
    ).matching_pair_work

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 29, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['komagata@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんのペアワーク【 ペア確定済みのペアワークです(タイトル) 】のペアがsotugyouさんに決定しました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'matching_pair_work to mute email notification or retired user' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:hatsuno)
    Watch.create!(user: receiver, watchable: pair_work)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.matching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.matching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.matching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.matching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
  end

  test 'rematching_pair_work' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    ActivityMailer.rematching_pair_work(
      receiver:,
      pair_work:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 30, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] ペアワーク【 ペア確定済みのペアワークです(タイトル) 】のペアがsotugyouさんに変更になりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'rematching_pair_work with params' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    mailer = ActivityMailer.with(
      receiver:,
      pair_work:
    ).rematching_pair_work

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 30, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] ペアワーク【 ペア確定済みのペアワークです(タイトル) 】のペアがsotugyouさんに変更になりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'rematching_pair_work to mute email notification or retired user' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.rematching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.rematching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.rematching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.rematching_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test 'reschedule_pair_work' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    ActivityMailer.reschedule_pair_work(
      receiver:,
      pair_work:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 31, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] ペアワーク【 ペア確定済みのペアワークです(タイトル) 】の日程が2025年01月02日(木) 01:00に変更になりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'reschedule_pair_work with params' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    mailer = ActivityMailer.with(
      receiver:,
      pair_work:
    ).reschedule_pair_work

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 31, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] ペアワーク【 ペア確定済みのペアワークです(タイトル) 】の日程が2025年01月02日(木) 01:00に変更になりました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'reschedule_pair_work to mute email notification or retired user' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.reschedule_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.reschedule_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.reschedule_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.reschedule_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test 'cancel_pair_work' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    ActivityMailer.cancel_pair_work(
      receiver:,
      pair_work:
    ).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 32, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんのペアワーク【 ペア確定済みのペアワークです(タイトル) 】のペア確定が取り消されました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'cancel_pair_work with params' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    mailer = ActivityMailer.with(
      receiver:,
      pair_work:
    ).cancel_pair_work

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    query = CGI.escapeHTML({ kind: 32, link: "/pair_works/#{pair_work.id}" }.to_param)
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['kimura@fjord.jp'], email.to
    assert_equal '[FBC] kimuraさんのペアワーク【 ペア確定済みのペアワークです(タイトル) 】のペア確定が取り消されました。', email.subject
    assert_match(%r{<a .+ href="http://localhost:3000/notification/redirector\?#{query}">ペアワークのページへ</a>}, email.body.to_s)
  end

  test 'cancel_pair_work to mute email notification or retired user' do
    pair_work = pair_works(:pair_work2)
    receiver = users(:kimura)

    receiver.update_columns(mail_notification: false, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.cancel_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: false, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.cancel_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: Date.current) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.cancel_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_empty ActionMailer::Base.deliveries

    receiver.update_columns(mail_notification: true, retired_on: nil) # rubocop:disable Rails/SkipsModelValidations
    ActivityMailer.cancel_pair_work(receiver:, pair_work: pair_work.reload).deliver_now
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  private

  def mailer_url_options
    Rails.application.config.action_mailer.default_url_options || {}
  end

  def full_url_for(path)
    opts = mailer_url_options
    host = opts[:host]
    port = opts[:port]
    protocol = opts[:protocol] || 'http'
    base = "#{protocol}://#{host}"
    base += ":#{port}" if port
    path = "/#{path}" unless path.start_with?('/')
    "#{base}#{path}"
  end

  def expected_redirector_href(query)
    # query is HTML-escaped (e.g., "kind=3&amp;link=%2Fproducts%2F1").
    raw = CGI.unescapeHTML(query)
    params = Rack::Utils.parse_nested_query(raw)
    expected_url = Rails.application.routes.url_helpers.notification_redirector_url(
      link: params['link'],
      kind: params['kind']
    )
    Regexp.escape(expected_url.gsub('&', '&amp;'))
  end
end
