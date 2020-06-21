# frozen_string_literal: true

class AddGraduationWorkToWorks < ActiveRecord::Migration[6.0]
  def change
    add_column :works, :graduation_work, :boolean, default: false, null: false
  end
end
