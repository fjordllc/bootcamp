class AddSourceIdToPractices < ActiveRecord::Migration[6.1]
  def change
    add_column :practices, :source_id, :integer
  end
end
