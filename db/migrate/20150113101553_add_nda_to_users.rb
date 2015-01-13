class AddNdaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nda, :boolean, null: false, default: true
  end
end
