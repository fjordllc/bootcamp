# frozen_string_literal: true

require 'test_helper'

class CreateFollowupCommentTest < ActiveSupport::TestCase
  test 'call' do
    target = User.create!(
      login_name: 'thirty',
      email: 'thirty@fjord.jp',
      password: 'testtest',
      name: '入会 三十郎',
      name_kana: 'ニュウカイ サンジュウロウ',
      description: '入会30日経過したユーザーです',
      course: courses(:course1),
      job: 'student',
      os: 'mac',
      experiences: 2,
      hibernated_at: nil,
      created_at: Time.current - 30.days,
      sent_student_followup_message: false
    )

    CreateFollowupComment.call(student: target)

    assert target.sent_student_followup_message
  end
end
