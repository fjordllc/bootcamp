class RemoveIndexPairWorkIdFromPairWorkSchedules < ActiveRecord::Migration[8.1]
  def change
    remove_index :pair_work_schedules, :pair_work_id, name: "index_pair_work_schedules_on_pair_work_id"
  end
end
