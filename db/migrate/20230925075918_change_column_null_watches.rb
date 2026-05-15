class ChangeColumnNullWatches < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:watches, :watchable_type, false)
    change_column_null(:watches, :watchable_id, false)
    change_column_null(:watches, :user_id, false)
  end
end
