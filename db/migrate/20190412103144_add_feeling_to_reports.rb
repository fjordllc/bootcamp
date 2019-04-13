# frozen_string_literal: true

class AddFeelingToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :feeling, :integer
  end
end
