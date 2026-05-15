class CreateLearningTimeFramesUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_time_frames_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :learning_time_frame, null: false, foreign_key: true

      t.timestamps
    end
  end
end
