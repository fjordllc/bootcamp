# frozen_string_literal: true

require "test_helper"

class LearningTimeTest < ActiveSupport::TestCase
  test "学習時間が日付を跨いだ時、終了時間が次の日になる" do
    learning_time = LearningTime.create!(report: reports(:report_8), started_at: "2018-03-11 23:00:00", finished_at: "2018-03-11 02:00:00")
    assert learning_time.finished_at == Time.zone.parse("2018-03-12 02:00:00")
  end

  test "学習時間が日付を跨がなかった時、終了時間を変更しない" do
    learning_time = LearningTime.create!(report: reports(:report_8), started_at: "2018-03-11 22:00:00", finished_at: "2018-03-11 23:00:00")
    assert learning_time.finished_at == Time.zone.parse("2018-03-11 23:00:00")
  end
end
