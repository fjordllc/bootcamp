class AddCorrectDefaultOnStatements < ActiveRecord::Migration[6.1]
  def change
    change_column_default :statements, :correct?, false
  end
end
