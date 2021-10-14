class RenameOpenColumnToCourses < ActiveRecord::Migration[6.1]
  def change
    rename_column :courses, :open, :published
  end
end
