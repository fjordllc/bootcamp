class AddWorksToContacts < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :work_time_cd, :integer
    add_column :contacts, :work_days_cd, :integer
  end
end
