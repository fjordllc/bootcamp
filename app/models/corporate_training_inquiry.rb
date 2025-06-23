# frozen_string_literal: true

class CorporateTrainingInquiry < ApplicationRecord
  include Commentable

  validates :company_name, presence: true
  validates :name, presence: true
  validates :email, presence: true,
                    format: {
                      with: URI::MailTo::EMAIL_REGEXP,
                      message: 'Emailに使える文字のみ入力してください'
                    }
  validates :meeting_date1, presence: true
  validates :meeting_date2, presence: true
  validates :meeting_date3, presence: true
  validates :participants_count, presence: true
  validates :training_duration, presence: true
  validates :how_did_you_hear, presence: true
  validates :additional_information, length: { maximum: 10_000 }
  validates :privacy_policy, acceptance: { message: 'に同意してください' }
  validate :unique_meeting_dates
  validate :meeting_dates_not_in_past

  private

  def unique_meeting_dates
    return unless [meeting_date1, meeting_date2, meeting_date3].uniq.length < 3

    errors.add(:base, '研修打ち合わせ希望日時はそれぞれ別の日付を選択してください')
  end

  def meeting_dates_not_in_past
    [meeting_date1, meeting_date2, meeting_date3].each do |meeting_date|
      return errors.add(:base, '研修打ち合わせ希望日時に過去の日付は入力できません') if meeting_date.present? && meeting_date < Time.zone.today
    end
  end
end
