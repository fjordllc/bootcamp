class AddHibernatedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :hibernated_at, :datetime
  end
end
