class AddGraduationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :graduation, :boolean, null: false, default: false
  end
end
