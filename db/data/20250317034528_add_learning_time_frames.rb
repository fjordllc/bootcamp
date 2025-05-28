# frozen_string_literal: true

class AddLearningTimeFrames < ActiveRecord::Migration[6.1]
  def up
    week_days = { '日' => 'sun', '月' => 'mon', '火' => 'tue', '水' => 'wed', '木' => 'thu', '金' => 'fri', '土' => 'sat' }

    week_days.each_with_index do |(day_name, _day_prefix), day_index|
      (0..23).each_with_index do |hour, hour_index|
        LearningTimeFrame.create!(
          id: day_index * 24 + hour_index + 1,
          week_day: day_name,
          activity_time: hour
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
