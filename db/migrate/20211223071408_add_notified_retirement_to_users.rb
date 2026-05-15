class AddNotifiedRetirementToUsers< ActiveRecord::Migration[6.1]
  def change
    add_column :users, :notified_retirement, :boolean, default: false, null: false
  end
end
