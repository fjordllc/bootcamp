class AddTrainingCompletedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :training_completed_at, :datetime
  end
end
