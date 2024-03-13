class AddEditorToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :editor, :string
  end
end
