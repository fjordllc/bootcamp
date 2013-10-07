class AddPositionToPractices < ActiveRecord::Migration
  def change
    add_column :practices, :position, :integer
  end
end
