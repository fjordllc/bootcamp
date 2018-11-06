# frozen_string_literal: true

class ChangeFootprintableToFootprints < ActiveRecord::Migration[5.2]
  def change
    rename_column :footprints, :report_id, :footprintable_id
    add_column :footprints, :footprintable_type, :string, default: "Report"
  end
end
