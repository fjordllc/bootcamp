class AddRowOrderToPractices < ActiveRecord::Migration[4.2]
  def change
    add_column :practices, :row_order, :integer
  end
end
