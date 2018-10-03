class ChangeCheckableIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :checks, name: "index_checks_on_user_id_and_checkable_id"
    add_index :checks, [:user_id, :checkable_id, :checkable_type], unique: true
  end
end
