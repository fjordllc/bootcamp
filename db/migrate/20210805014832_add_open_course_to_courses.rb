class AddOpenCourseToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :open_course, :boolean, default: false, null: false
  end
end
