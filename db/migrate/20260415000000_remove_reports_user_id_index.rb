# frozen_string_literal: true

class RemoveReportsUserIdIndex < ActiveRecord::Migration[7.2]
  def up
    remove_index :reports, name: 'reports_user_id', if_exists: true
  end

  def down
    add_index :reports, :user_id, name: 'reports_user_id', if_not_exists: true
  end
end
