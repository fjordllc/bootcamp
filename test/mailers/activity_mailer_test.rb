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

  test 'graduated with user who have been denied' do
    ActivityMailer.graduated(
      sender: users(:sotugyou),
      receiver: users(:hajime)
    ).deliver_now

    assert ActionMailer::Base.deliveries.empty?
  end

  test 'came_answer' do
    answer = answers(:answer3)
    ActivityMailer.came_answer(answer: answer).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんから回答がありました。', email.subject
    assert_match(/回答/, email.body.to_s)
  end

  test 'came_answer with params' do
    answer = answers(:answer3)
    mailer = ActivityMailer.with(answer: answer).came_answer

    perform_enqueued_jobs do
      mailer.deliver_later
    end

    assert_not ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['noreply@bootcamp.fjord.jp'], email.from
    assert_equal ['sotugyou@example.com'], email.to
    assert_equal '[FBC] komagataさんから回答がありました。', email.subject
    assert_match(/回答/, email.body.to_s)
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
end
