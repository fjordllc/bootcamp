# frozen_string_literal: true

class UserNegativeStreak
  def initialize(user)
    @user = user
  end

  def depressed?
    reported_reports = @user.reports.order(reported_on: :desc).limit(User::DEPRESSED_SIZE)
    reported_reports.size == User::DEPRESSED_SIZE && reported_reports.all?(&:negative?)
  end

  def raw_last_negative_report_id
    @user.reports.where(emotion: 'negative')
         .order(reported_on: :desc)
         .limit(1)
         .pluck(:id)
         .try(:first)
  end

  def update_negative_streak
    @user.negative_streak = depressed?
    @user.last_negative_report_id = raw_last_negative_report_id
    @user.save!(validate: false)
  end
end
