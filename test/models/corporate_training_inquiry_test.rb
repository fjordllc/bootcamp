# frozen_string_literal: true

require 'test_helper'

class CorporateTrainingInquiryTest < ActiveSupport::TestCase
  test '#unique_meeting_dates' do
    corporate_training_inquiry = corporate_training_inquiries(:corporate_training_inquiry1)
    corporate_training_inquiry.meeting_date1 = Time.zone.parse('2030-01-01-10:00')
    corporate_training_inquiry.meeting_date2 = corporate_training_inquiry.meeting_date1
    assert_not corporate_training_inquiry.valid?
    assert_includes corporate_training_inquiry.errors[:base], '研修打ち合わせ希望日時はそれぞれ別の日付を選択してください'
  end

  test '#meeting_dates_not_in_past' do
    corporate_training_inquiry = corporate_training_inquiries(:corporate_training_inquiry1)
    corporate_training_inquiry.meeting_date1 = Time.zone.today - 1.day
    assert_not corporate_training_inquiry.valid?
    assert_includes corporate_training_inquiry.errors[:base], '研修打ち合わせ希望日時に過去の日付は入力できません'
  end
end
