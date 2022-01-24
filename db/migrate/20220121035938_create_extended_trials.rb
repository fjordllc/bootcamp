class CreateExtendedTrials < ActiveRecord::Migration[6.1]
  def change
    create_table :extended_trials do |t|
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :title, null: false
      t.timestamps
    end
  end
end
