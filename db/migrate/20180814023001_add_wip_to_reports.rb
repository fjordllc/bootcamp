# frozen_string_literal: true

class AddWipToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :wip, :boolean, null: false, default: false
  end
end
