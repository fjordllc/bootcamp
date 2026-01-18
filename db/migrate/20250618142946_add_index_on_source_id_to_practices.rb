class AddIndexOnSourceIdToPractices < ActiveRecord::Migration[6.1]
  def change
    add_index :practices, :source_id
  end
end
