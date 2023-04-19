class AddIndexToWatches < ActiveRecord::Migration[6.1]
  def change
    add_index :watches, [:watchable_type, :watchable_id, :user_id], unique: true
  end
end
