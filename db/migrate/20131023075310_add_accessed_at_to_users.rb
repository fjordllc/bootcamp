class AddAccessedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :accessed_at, :datetime
  end
end
