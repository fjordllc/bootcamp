# frozen_string_literal: true

class AddTraineeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :trainee, :boolean, default: false, null: false
  end
end
