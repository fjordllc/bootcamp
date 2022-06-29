class AddCategoryToRegularEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :regular_events, :category, :integer, null: false, default: 0
  end
end
