class AddFirstNameKanaAndLastNameKanaToGrantCourseApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :grant_course_applications, :first_name_kana, :string, default: "", null: false
    add_column :grant_course_applications, :last_name_kana, :string, default: "", null:false
  end
end
