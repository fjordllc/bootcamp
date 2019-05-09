# frozen_string_literal: true

class Grass
  def self.times(user, end_date)
    start_date = end_date.prev_year.sunday
    sql = <<-SQL
WITH series AS (
  SELECT
    date
  FROM
    generate_series(:start_date::DATE, :end_date, '1 day') AS series(date)
  ),
  summary AS (
    SELECT
      reported_on AS date,
      EXTRACT(epoch FROM SUM(finished_at - started_at)) / 60 / 60 AS total_hour
    FROM
      learning_times JOIN reports ON learning_times.report_id = reports.id
    WHERE
      reports.user_id = :user_id
    GROUP BY
      reported_on
    ORDER BY
      reported_on
  )
SELECT
  series.date AS date,
  CASE
    WHEN summary.total_hour > 6 THEN 4
    WHEN 6 >= summary.total_hour AND summary.total_hour > 4 THEN 3
    WHEN 4 >= summary.total_hour AND summary.total_hour > 2 THEN 2
    WHEN 2 >= summary.total_hour AND summary.total_hour > 0 THEN 1
    ELSE 0
  END AS velocity
FROM
  series
LEFT JOIN
  summary ON series.date = summary.date
		SQL

    LearningTime.find_by_sql([sql, { start_date: start_date, end_date: end_date, user_id: user.id }])
  end
end
