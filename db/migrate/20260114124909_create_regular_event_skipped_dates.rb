class CreateRegularEventSkippedDates < ActiveRecord::Migration[8.1]
  def change
    create_table :regular_event_skipped_dates do |t|
      t.string :reason
      t.datetime :skipped_at
      t.references :regular_event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
