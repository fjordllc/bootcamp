# frozen_string_literal: true

class AddPjordCommentToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pjord_comment, :boolean, default: true, null: false
  end
end
