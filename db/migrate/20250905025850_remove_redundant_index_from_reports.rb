# frozen_string_literal: true

class RemoveRedundantIndexFromReports < ActiveRecord::Migration[6.1]
  def change
    remove_index :reports, name: 'idx_reports_user_date'
  end
end
