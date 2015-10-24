class AddUserIdUpdatedToReports < ActiveRecord::Migration
  def change
    add_column :reports, :user_id_updated, :integer
  end
end
