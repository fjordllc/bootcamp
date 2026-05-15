# frozen_string_literal: true

class CreateLearningMinuteStatistics < ActiveRecord::Migration[6.0]
  def change
    create_table :learning_minute_statistics do |t|
      t.belongs_to :practice, foreign_key: true
      t.integer :average, null: false
      t.integer :median, null: false

      t.timestamps
    end
  end
end
