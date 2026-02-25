class CreateRegularEventSkipDates < ActiveRecord::Migration[8.1]
  def change
    create_table :regular_event_skip_dates do |t|
      t.date :skip_on, null: false
      t.text :reason
      t.references :regular_event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :regular_event_skip_dates,
              [:regular_event_id, :skip_on],
              unique: true
  end
end
