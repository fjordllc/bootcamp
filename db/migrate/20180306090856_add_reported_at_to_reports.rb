class AddReportedAtToReports < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :reported_at, :date
  end
end
