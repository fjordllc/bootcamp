class RemoveWastedColumnsFromContacts < ActiveRecord::Migration[5.0]
  def change
    remove_column :contacts, :blog_url, :string
    remove_column :contacts, :github_account, :string
    remove_column :contacts, :work_time, :string
    remove_column :contacts, :work_days, :string
    remove_column :contacts, :has_mac_cd, :integer
  end
end
