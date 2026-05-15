class RemoveUnusedIndicesFromRegularEvents < ActiveRecord::Migration[8.1]
  def change
    remove_index :regular_events, column: :finished
    remove_index :regular_events, column: :start_at
    remove_index :regular_events, column: :end_at
  end
end
