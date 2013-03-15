class AddRowOrderToPractices < ActiveRecord::Migration
  def change
    add_column :practices, :row_order, :integer
  end
end
