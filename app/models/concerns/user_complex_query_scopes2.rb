# frozen_string_literal: true

module UserComplexQueryScopes2
  extend ActiveSupport::Concern

  included do
    scope :delayed, lambda {
      sql = Learning.select(:user_id, 'MAX(updated_at) AS completed_at')
                    .where(status: :complete)
                    .group(:user_id).to_sql

      students_and_trainees
        .joins("JOIN (#{sql}) learnings ON users.id = user_id")
        .select('users.*', :completed_at)
        .where('completed_at <= ?', 2.weeks.ago.end_of_day)
    }
    scope :currently_learning_except, lambda { |user|
      students_and_trainees
        .joins(:learning_time_frames)
        .merge(LearningTimeFrame.active_now)
        .where.not(id: user.id)
        .with_attached_avatar
    }
  end
end
