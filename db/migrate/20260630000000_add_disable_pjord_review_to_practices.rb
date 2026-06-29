# frozen_string_literal: true

class AddDisablePjordReviewToPractices < ActiveRecord::Migration[8.0]
  def change
    add_column :practices, :disable_pjord_review, :boolean, null: false, default: false
  end
end
