class AddSlackAccountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :slack_account, :string
  end
end
