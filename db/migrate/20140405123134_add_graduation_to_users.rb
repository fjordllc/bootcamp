class AddGraduationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :graduation, :boolean, null: false, default: false
  end
end
