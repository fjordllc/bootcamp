class CreateLearningTimeFrames < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_time_frames do |t|
      t.string :week_day
      t.integer :activity_time

      t.timestamps
    end
  end
end
