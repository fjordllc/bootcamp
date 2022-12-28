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
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] sotugyouさんが卒業しました。', email.subject
    assert_match(/卒業/, email.body.to_s)
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
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['mentormentaro@fjord.jp'], email.to
    assert_equal '[FBC] sotugyouさんが卒業しました。', email.subject
    assert_match(/卒業/, email.body.to_s)
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
      comment: comment,
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
      comment: comment,
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
end
