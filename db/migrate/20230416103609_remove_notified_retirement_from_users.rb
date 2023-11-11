class RemoveNotifiedRetirementFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :notified_retirement, :boolean, default: false, null: false
  end
end
