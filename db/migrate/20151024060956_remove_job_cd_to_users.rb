# frozen_string_literal: true

class RemoveJobCdToUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :job_cd, :string
  end
end
