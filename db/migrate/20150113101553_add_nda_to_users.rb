class AddNdaToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :nda, :boolean, null: false, default: true
  end
end
