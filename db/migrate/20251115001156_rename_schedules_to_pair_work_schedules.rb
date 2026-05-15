class RenameSchedulesToPairWorkSchedules < ActiveRecord::Migration[8.1]
  def change
    rename_table :schedules, :pair_work_schedules
  end
end
