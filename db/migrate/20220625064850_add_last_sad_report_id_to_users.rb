class AddLastSadReportIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_sad_report_id, :integer
  end
end
