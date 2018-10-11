# frozen_string_literal: true

class AddFindJobAssistToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :find_job_assist, :boolean, null: false, default: false
  end
end
