# frozen_string_literal: true

class ChangeCheckableToChecks < ActiveRecord::Migration[5.1]
  def change
    rename_column :checks, :report_id, :checkable_id
    add_column :checks, :checkable_type, :string, default: "Report"
  end
end
