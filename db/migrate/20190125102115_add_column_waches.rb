class AddColumnWaches < ActiveRecord::Migration[5.2]
  def change
    add_column :watches, :user_id, :integer
  end
end
