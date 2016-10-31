class AddSlackAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slack_account, :string
  end
end
