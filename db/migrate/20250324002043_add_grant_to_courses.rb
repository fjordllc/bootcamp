class AddGrantToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :grant, :boolean, default: false, null: false
  end
end
