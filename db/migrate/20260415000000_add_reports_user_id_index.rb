# frozen_string_literal: true

class AddReportsUserIdIndex < ActiveRecord::Migration[7.2]
  def change
    add_index :reports, :user_id, name: 'reports_user_id', if_not_exists: true
  end
end
