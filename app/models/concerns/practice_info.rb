# frozen_string_literal: true

module PracticeInfo
  extend ActiveSupport::Concern

  def away?
    last_activity_at && (last_activity_at <= 10.minutes.ago)
  end

  def active?
    (last_activity_at && (last_activity_at > 1.month.ago)) || created_at > 1.month.ago
  end

  def submitted?(coding_test)
    coding_test_submissions.exists?(coding_test_id: coding_test.id)
  end

  def checked_product_of?(*practices)
    products.where(practice: practices).any?(&:checked?)
  end

  def practices_with_checked_product
    Practice.where(products: products.checked)
  end

  def practice_ids_skipped
    skipped_practices.pluck(:practice_id)
  end

  def total_learning_time
    sql = <<~SQL
      SELECT
        SUM(EXTRACT(epoch from learning_times.finished_at - learning_times.started_at) / 60 / 60) AS total
      FROM
        learning_times JOIN reports ON learning_times.report_id = reports.id
      WHERE
        reports.user_id = :user_id
    SQL

    learning_time = LearningTime.find_by_sql([sql, { user_id: id }])
    learning_time.first.total || 0
  end

  def elapsed_days
    if graduated_on.present?
      (graduated_on.to_date - created_at.to_date).to_i
    else
      (Date.current - created_at.to_date).to_i
    end
  end

  def training_remaining_days
    (training_ends_on - Time.zone.today).to_i
  end

  def grant_course?
    course = Course.find_by(id: course_id)
    course_id.present? && course&.grant?
  end

  private

  def practices_include_progress
    course.practices.where(include_progress: true)
  end

  def required_practices_size_with_skip
    course.practices.where(id: practice_ids_skipped, include_progress: true).size
  end
end
