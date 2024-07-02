class RenameRegularEventHolidaysToRegularEventCustomHolidays < ActiveRecord::Migration[6.1]
  def change
    rename_table :regular_event_holidays, :regular_event_custom_holidays
  end
end
