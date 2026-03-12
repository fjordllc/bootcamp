class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :pair_work, null: false, foreign_key: true
      t.timestamp :proposed_at, null: false

      t.timestamps
    end
  end
end
