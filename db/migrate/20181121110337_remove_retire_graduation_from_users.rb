# frozen_string_literal: true

class RemoveRetireGraduationFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :retire
    remove_column :users, :graduation
  end
end
