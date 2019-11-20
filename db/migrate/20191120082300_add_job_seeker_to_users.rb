# frozen_string_literal: true

class AddJobSeekerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :job_seeker, :boolean, default: false, null: false
  end
end
