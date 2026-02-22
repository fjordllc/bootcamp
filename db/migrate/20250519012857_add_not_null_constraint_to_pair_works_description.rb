class AddNotNullConstraintToPairWorksDescription < ActiveRecord::Migration[8.1]
  def change
    change_column_null :pair_works, :description, false
  end
end
