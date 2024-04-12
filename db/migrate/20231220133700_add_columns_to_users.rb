class AddColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :editor, :integer
    add_column :users, :other_editor, :string
  end
end
