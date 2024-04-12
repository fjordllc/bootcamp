class CreateRegularEventHolidays < ActiveRecord::Migration[6.1]
  def change
    create_table :regular_event_holidays do |t|
      t.references :regular_event, null: false, foreign_key: true
      t.date :holiday_date, null: false
      t.text :description

      t.timestamps
    end
  end
end
