class ChangeCommentsDescriptionToNotNull < ActiveRecord::Migration[8.1]
  def change
    change_column_null :comments, :description, false
  end
end
