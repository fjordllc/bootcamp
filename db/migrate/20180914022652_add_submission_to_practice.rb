# frozen_string_literal: true

class AddSubmissionToPractice < ActiveRecord::Migration[5.2]
  def change
    add_column :practices, :submission, :boolean, default: true, null: false
  end
end
