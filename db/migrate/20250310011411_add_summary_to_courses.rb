class AddSummaryToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :summary, :text
  end
end
