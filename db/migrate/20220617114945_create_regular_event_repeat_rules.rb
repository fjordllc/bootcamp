class CreateRegularEventRepeatRules < ActiveRecord::Migration[6.1]
  def change
    create_table :regular_event_repeat_rules do |t|
      t.references :regular_event, foreign_key: true
      t.integer :frequency, null: false
      t.integer :day_of_the_week, null: false
      t.timestamps
    end
  end
end
