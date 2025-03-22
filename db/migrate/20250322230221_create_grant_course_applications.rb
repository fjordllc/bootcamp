class CreateGrantCourseApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :grant_course_applications do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :address, null: false
      t.string :phone, null: false
      t.boolean :trial_period, default: false, null: false

      t.timestamps
    end
  end
end
