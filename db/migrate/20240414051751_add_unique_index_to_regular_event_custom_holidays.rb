class AddUniqueIndexToRegularEventCustomHolidays < ActiveRecord::Migration[6.1]
  def change
    add_index :regular_event_custom_holidays, [:regular_event_id, :holiday_date], unique: true, name: 'index_unique_regular_event_and_holiday_date'
  end
end
