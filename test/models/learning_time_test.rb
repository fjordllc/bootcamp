require "test_helper"

class LearningTimeTest < ActiveSupport::TestCase
  def create_report(learning_time_params)
    report = reports(:report_2)
    report.learning_times.build(learning_time_params)
    report.save
    report
  end

  test "after save, finished day does not change" do
    report = create_report({ started_at: Time.new(2018, 1, 20, 9, 0, 0), finished_at: Time.new(2018, 1, 20, 22, 0, 0) })
    learning_time = report.learning_times.first
    assert_equal learning_time.finished_at.day, 20
  end

  test "after first save, finished day become next day, and after update, become previous day" do
    report = create_report({ started_at: Time.new(2018, 1, 20, 23, 0, 0), finished_at: Time.new(2018, 1, 20, 0, 0, 0) })
    learning_time = report.learning_times.first
    assert_equal learning_time.finished_at.day, 21

    old_finished_at = learning_time.finished_at
    learning_time.update(finished_at: Time.new(old_finished_at.year, old_finished_at.month, old_finished_at.day, 23, 30, 0))
    assert_equal learning_time.finished_at.day, 20
  end

  test "after first save, finished day become next day, and after update, does not change" do
    report = create_report({ started_at: Time.new(2018, 12, 31, 22, 0, 0), finished_at: Time.new(2018, 12, 31, 0, 0, 0) })
    learning_time = report.learning_times.first
    assert_equal learning_time.finished_at.day, 1

    old_finished_at = learning_time.finished_at
    learning_time.update(finished_at: Time.new(old_finished_at.year, old_finished_at.month, old_finished_at.day, 7, 0, 0))
    assert_equal learning_time.finished_at.day, 1
  end
end
