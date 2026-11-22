# frozen_string_literal: true

require 'test_helper'

class QuestionCallbacksTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @questioner = users(:kimura)
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify all mentors when a question is created as published' do
    assert_difference -> { came_question_notifications.count }, User.mentor.count do
      @question = create_question(title: '公開タイトル')
    end

    notification = notification_to_komagata(@question)
    assert_equal 'kimuraさんから質問「公開タイトル」が投稿されました。', notification.message
    assert_equal @questioner, notification.sender
  end

  test 'does not notify the mentor who posted the question' do
    mentor = users(:mentormentaro)

    assert_difference -> { came_question_notifications.count }, User.mentor.count - 1 do
      create_question(user: mentor)
    end
    assert_not came_question_notifications.exists?(user: mentor, sender: mentor)
  end

  test 'does not notify when a question is created or updated as WIP' do
    assert_no_difference -> { came_question_notifications.count } do
      question = create_question(wip: true)
      update_question(question, title: '更新されたWIPタイトル', description: '更新されたWIP本文')
    end
  end

  test 'notify when a WIP question is published' do
    question = create_question(title: 'WIPタイトル', wip: true)

    assert_difference -> { came_question_notifications.count }, User.mentor.count do
      update_question(question, wip: false)
    end
    assert_equal 'kimuraさんから質問「WIPタイトル」が投稿されました。', notification_to_komagata(question).message
  end

  test 'notify with the modified title when a WIP question is modified and published' do
    question = create_question(title: 'WIPタイトル', wip: true)

    assert_difference -> { came_question_notifications.count }, User.mentor.count do
      update_question(question, title: '更新された公開タイトル', description: '更新された公開本文', wip: false)
    end
    assert_equal 'kimuraさんから質問「更新された公開タイトル」が投稿されました。', notification_to_komagata(question).message
  end

  test 'does not notify again when a published question is updated' do
    [questions(:question8), create_question].each do |question|
      assert_no_difference -> { came_question_notifications.count } do
        update_question(question, title: '更新されたタイトル', description: '更新された本文')
      end
    end
  end

  test 'does not notify again when a published question is saved as WIP' do
    question = create_question

    assert_no_difference -> { came_question_notifications.count } do
      update_question(question, wip: true)
      update_question(question, title: '更新されたWIPタイトル', description: '更新されたWIP本文')
    end
  end

  test 'delete notifications when a question is destroyed' do
    question = create_question
    assert Notification.exists?(link: "/questions/#{question.id}")

    question.destroy!

    assert_not Notification.exists?(link: "/questions/#{question.id}")
  end

  private

  def came_question_notifications
    Notification.where(kind: :came_question)
  end

  def notification_to_komagata(question)
    came_question_notifications.find_by!(user: users(:komagata), link: "/questions/#{question.id}")
  end

  def create_question(user: @questioner, title: 'タイトル', wip: false)
    question = Question.create!(user:, title:, description: '本文', wip:)
    perform_enqueued_jobs
    question
  end

  def update_question(question, **attributes)
    question.update!(attributes)
    perform_enqueued_jobs
  end
end
