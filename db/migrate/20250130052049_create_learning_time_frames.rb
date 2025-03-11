class CreateLearningTimeFrames < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_time_frames do |t|
      t.string :week_day, null: false
      t.integer :activity_time, null: false

      t.timestamps
    end
  end
end
