# frozen_string_literal: true

class CreateMemos < ActiveRecord::Migration[5.2]
  def change
    create_table :memos do |t|
      t.date :date
      t.string :body

      t.timestamps
    end
  end
end
