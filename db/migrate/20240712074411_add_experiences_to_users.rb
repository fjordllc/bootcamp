class AddExperiencesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :experiences, :integer, null: false, default: 0
  end
end
