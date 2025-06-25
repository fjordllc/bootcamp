class RemoveExperienceFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :experience, :integer
  end
end
