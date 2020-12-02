# frozen_string_literal: true

class RemoveRetireGraduationFromUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.remove :retire
      t.remove :graduation
    end
  end
end
