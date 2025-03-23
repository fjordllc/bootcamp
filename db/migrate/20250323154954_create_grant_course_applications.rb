class CreateGrantCourseApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :grant_course_applications do |t|
      t.string :email, null: false
      t.boolean :trial_period, default: false, null: false
      t.string :last_name, null: false
      t.string :first_name, null: false
      t.string :zip1, null: false
      t.string :zip2, null: false
      t.integer :prefecture_code, null: false
      t.string :address1, null: false
      t.string :address2
      t.string :tel1, null: false
      t.string :tel2, null: false
      t.string :tel3, null: false

      t.timestamps
    end
    add_index :grant_course_applications, :email
  end
end
