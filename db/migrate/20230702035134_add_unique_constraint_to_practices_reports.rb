class AddUniqueConstraintToPracticesReports < ActiveRecord::Migration[6.1]
  def change
    remove_index :practices_reports, [:practice_id, :report_id]
    add_index :practices_reports, [:practice_id, :report_id], unique: true
  end
end
