# frozen_string_literal: true

require 'test_helper'

class Scheduler::Daily::SendMessageControllerTest < ActionDispatch::IntegrationTest
  test '#show marks hibernated students as sent_student_followup_message' do
    original_token = ENV.fetch('TOKEN', nil)
    ENV['TOKEN'] = 'test_token'

    CreateFollowupComment.stub(:call, true) do
      get scheduler_daily_send_message_path(token: 'test_token')
    end

    assert_response :success
    assert_not users(:komagata).sent_student_followup_message
    assert users(:kyuukai).reload.sent_student_followup_message
  ensure
    ENV['TOKEN'] = original_token
  end
end
