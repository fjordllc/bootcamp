class RemoveRowOrderToPractices < ActiveRecord::Migration
  def change
    remove_column :practices, :row_order
  end
end
