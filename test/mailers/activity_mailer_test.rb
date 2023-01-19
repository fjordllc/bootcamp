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
end
