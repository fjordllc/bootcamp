class AddForeignKeyConstraintToCheckerIdInProducts < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :products, :users, column: :checker_id
  end
end
