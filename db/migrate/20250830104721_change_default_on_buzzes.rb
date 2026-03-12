class ChangeDefaultOnBuzzes < ActiveRecord::Migration[6.1]
  def change
    change_column_default :buzzes, :url, from: "", to: nil
    change_column_default :buzzes, :title, from: "", to: nil
    change_column_default :buzzes, :published_at, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
    change_column_default :buzzes, :memo, from: "", to: nil
  end
end
