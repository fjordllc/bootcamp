# frozen_string_literal: true

class ChangeCommentableToComments < ActiveRecord::Migration[5.1]
  def change
    rename_column :comments, :report_id, :commentable_id
    add_column :comments, :commentable_type, :string, default: "Report"
  end
end
