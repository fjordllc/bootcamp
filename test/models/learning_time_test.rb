# frozen_string_literal: true

require "test_helper"

class LearningTimeTest < ActiveSupport::TestCase
  test "canonicalize_finished_at when started_at is latter than finished_at" do
    learning_time = LearningTime.create!(report: reports(:report_8), started_at: "2017-01-01 23:00:00", finished_at: "2017-01-01 02:00:00")
    assert_equal(Time.zone.parse("2017-01-02 02:00:00"), learning_time.finished_at)
  end

  test "canonicalize_finished_at when started_at isn't latter than finished_at " do
    learning_time = LearningTime.create!(report: reports(:report_8), started_at: "2017-01-01 22:00:00", finished_at: "2017-01-01 23:00:00")
    assert_equal(Time.zone.parse("2017-01-01 23:00:00"), learning_time.finished_at)
  end

  test "replace_date_with_reported_on" do
    learning_time = LearningTime.create!(report: reports(:report_8), started_at: "2017-01-02 22:00:00", finished_at: "2017-01-02 23:00:00")
    assert_equal(Time.zone.parse("2017-01-01 22:00:00"), learning_time.started_at)
    assert_equal(Time.zone.parse("2017-01-01 23:00:00"), learning_time.finished_at)
  end
end
