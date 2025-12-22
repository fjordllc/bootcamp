class AddColumnsToBuzzes < ActiveRecord::Migration[6.1]
  def up
    add_column :buzzes, :url, :string, default: ""
    add_column :buzzes, :title, :string, default: ""
    add_column :buzzes, :published_at, :date, default: -> { 'CURRENT_TIMESTAMP' }
    add_column :buzzes, :memo, :text, default: ""

    change_column_null :buzzes, :url, false
    change_column_null :buzzes, :title, false
    change_column_null :buzzes, :published_at, false
  end

  def down
    remove_column :buzzes, :url
    remove_column :buzzes, :title
    remove_column :buzzes, :published_at
    remove_column :buzzes, :memo
  end
end
