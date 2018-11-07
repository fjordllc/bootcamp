# frozen_string_literal: true

class ChangeReportedOnToReports < ActiveRecord::Migration[5.2]
  def change
    rename_column :reports, :reported_at, :reported_on
  end
end
