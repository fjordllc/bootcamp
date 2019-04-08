# frozen_string_literal: true

class AddJobSeekeingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :job_seeking, :boolean, default: false, null: false
  end
end
