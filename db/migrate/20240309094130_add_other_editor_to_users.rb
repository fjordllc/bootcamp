class AddOtherEditorToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :other_editor, :string
  end
end
