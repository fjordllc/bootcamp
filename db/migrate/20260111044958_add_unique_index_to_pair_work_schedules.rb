class AddUniqueIndexToPairWorkSchedules < ActiveRecord::Migration[8.1]
  def change
    add_index :pair_work_schedules, [:pair_work_id, :proposed_at], unique: true
  end
end
