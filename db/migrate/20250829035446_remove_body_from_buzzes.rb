class RemoveBodyFromBuzzes < ActiveRecord::Migration[6.1]
  def change
    remove_column :buzzes, :body, :text
  end
end
