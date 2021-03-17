# frozen_string_literal: true

class ChangeWipDefaultOnReports < ActiveRecord::Migration[6.0]
  def change
    change_column_default :reports, :wip, from: false, to: true
  end
end
