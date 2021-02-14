# frozen_string_literal: true

class ChangeEmotionToNotnullInReports < ActiveRecord::Migration[6.0]
  def change
    change_column :reports, :emotion, :integer, default: 2, null: false
  end
end
