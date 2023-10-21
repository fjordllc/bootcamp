class ChangeStatementsIsCorrectNotNullAndDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_null :statements, :is_correct, false
    change_column_default :statements, :is_correct, nil
  end
end
