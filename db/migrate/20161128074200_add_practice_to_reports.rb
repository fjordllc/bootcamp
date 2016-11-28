class AddPracticeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :practice_id, :integer
  end
end
