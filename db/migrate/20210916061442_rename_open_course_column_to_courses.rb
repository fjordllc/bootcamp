class RenameOpenCourseColumnToCourses < ActiveRecord::Migration[6.1]
  def change
    rename_column :courses, :open_course, :is_opened
  end
end
