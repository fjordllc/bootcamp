class AddCareerPathToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :career_path, :integer, null: false, default: 0
    add_column :users, :career_memo, :text
  end
end
