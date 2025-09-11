# frozen_string_literal: true

class AddReportsUserIdReportedOnIndexForLearningTime < ActiveRecord::Migration[6.1]
  def change
    add_index :reports, [:user_id, :reported_on], name: "idx_reports_user_date"
  end
end
