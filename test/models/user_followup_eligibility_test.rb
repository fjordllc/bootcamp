# frozen_string_literal: true

require 'test_helper'

class UserFollowupEligibilityTest < ActiveSupport::TestCase
  test '#after_twenty_nine_days_registration?' do
    over29days_registered_student = User.create!(
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
      created_at: Time.current - 30.days,
      sent_student_followup_message: false
    )
    recently_registered_student = User.create!(
      login_name: 'recently',
      email: 'recently_registered_student@fjord.jp',
      password: 'testtest',
      name: '入会 太郎',
      name_kana: 'ニュウカイ タロウ',
      description: '最近入会したユーザーです',
      course: courses(:course1),
      job: 'student',
      os: 'mac',
      experiences: 2,
      created_at: Time.current,
      sent_student_followup_message: false
    )

    assert UserFollowupEligibility.new(over29days_registered_student).send(:after_twenty_nine_days_registration?)
    assert_not UserFollowupEligibility.new(recently_registered_student).send(:after_twenty_nine_days_registration?)
  end
end
