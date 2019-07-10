# frozen_string_literal: true

class RenameColumnStatuscdToStatus < ActiveRecord::Migration[5.2]
  def change
    rename_column :learnings, :status_cd, :status
  end
end
