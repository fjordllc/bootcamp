# frozen_string_literal: true

class RemoveFindJobAssistFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :find_job_assist, :boolean, null: false, default: false
  end
end
