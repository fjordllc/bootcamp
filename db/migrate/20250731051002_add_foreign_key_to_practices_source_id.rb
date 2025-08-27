class AddForeignKeyToPracticesSourceId < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :practices, :practices, column: :source_id
  end
end
