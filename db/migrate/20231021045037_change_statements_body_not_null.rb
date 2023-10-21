class ChangeStatementsBodyNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :statements, :body, false
  end
end
