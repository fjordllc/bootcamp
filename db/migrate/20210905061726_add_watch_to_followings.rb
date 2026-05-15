class AddWatchToFollowings < ActiveRecord::Migration[6.1]
  def change
    add_column :followings, :watch, :boolean, default: true, null: false
  end
end
