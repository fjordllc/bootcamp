# frozen_string_literal: true

class CreateLearningTimes < ActiveRecord::Migration[5.1]
  def change
    create_table :learning_times do |t|
      t.references :report, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :finished_at, null: false
    end
  end
end
