class RemoveExperienceFromUsers < ActiveRecord::Migration[6.1]
  def up
    remove_column :users, :experience, :integer
  end

  def down
    add_column :users, :experience, :integer
  end
end
