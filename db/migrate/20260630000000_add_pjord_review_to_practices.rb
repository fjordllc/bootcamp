# frozen_string_literal: true

class AddPjordReviewToPractices < ActiveRecord::Migration[8.0]
  def change
    add_column :practices, :pjord_review, :boolean, null: false, default: true
  end
end
