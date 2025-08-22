# frozen_string_literal: true

class GrassLearningTimeQuery < Patterns::Query
  queries LearningTime

  def initialize(user, end_date, relation = LearningTime.all, start_date: nil)
    super(relation)
    @user = user
    @end_date = end_date
    @start_date = start_date || end_date.prev_year.sunday
  end

  private

  def query
    relation
      .from("(#{compiled_sql}) AS grass_data")
      .select(:date, :velocity)
  end

  def compiled_sql
    ActiveRecord::Base.send(:sanitize_sql_array, [sql_template, sql_params])
  end

  def sql_template
    <<~SQL
      WITH series AS (
        SELECT date FROM generate_series(:start_date::DATE, :end_date::DATE, '1 day') AS series(date)
      ), summary AS (
        SELECT
          reported_on AS date,
          EXTRACT(epoch FROM SUM(finished_at - started_at)) / 60 / 60 AS total_hour
        FROM learning_times
        JOIN reports ON learning_times.report_id = reports.id
        WHERE reports.user_id = :user_id
          AND reports.reported_on BETWEEN :start_date AND :end_date
        GROUP BY reported_on
      )
      SELECT
        series.date,
        CASE
          WHEN summary.total_hour > 6 THEN 4
          WHEN summary.total_hour > 4 THEN 3
          WHEN summary.total_hour > 2 THEN 2
          WHEN summary.total_hour > 0 THEN 1
          ELSE 0
        END AS velocity
      FROM series
      LEFT JOIN summary ON series.date = summary.date
      ORDER BY series.date
    SQL
  end

  def sql_params
    {
      start_date: @start_date,
      end_date: @end_date,
      user_id: @user.id
    }
  end
end
