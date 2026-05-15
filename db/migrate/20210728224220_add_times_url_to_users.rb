class AddTimesUrlToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :times_url, :string
  end
end
