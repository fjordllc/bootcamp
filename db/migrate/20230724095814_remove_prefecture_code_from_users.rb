class RemovePrefectureCodeFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :prefecture_code, :integer
  end
end
