# frozen_string_literal: true

class ChangeEmotionToNotnullInReports < ActiveRecord::Migration[6.0]
  def up
    change_column :reports, :emotion, :integer, default: 2, null: false
  end

  def down
    change_column :reports, :emotion, :integer, default: nil, null: true
  end
end
