# frozen_string_literal: true

class UserLearningTime
  def initialize(user)
    @user = user
  end

  def total
    sql = <<~SQL
      SELECT
        SUM(EXTRACT(epoch from learning_times.finished_at - learning_times.started_at) / 60 / 60) AS total
      FROM
        learning_times JOIN reports ON learning_times.report_id = reports.id
      WHERE
        reports.user_id = :user_id
    SQL

    learning_time = LearningTime.find_by_sql([sql, { user_id: @user.id }])
    learning_time.first.total || 0
  end
end
