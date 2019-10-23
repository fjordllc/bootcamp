# frozen_string_literal: true

class AddPrefecturesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :prefecture_code, :integer, null: true
  end
end
