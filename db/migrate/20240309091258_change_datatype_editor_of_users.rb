class ChangeDatatypeEditorOfUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :editor, 'integer USING CAST(editor AS integer)'
  end
end
