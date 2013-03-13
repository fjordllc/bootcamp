class AddNameKanaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name_kana, :string
  end
end
