# frozen_string_literal: true

class CreateJoinTablePracticesReports < ActiveRecord::Migration[4.2]
  def change
    create_join_table :practices, :reports do |t|
      t.index %i[practice_id report_id]
      t.index %i[report_id practice_id]
    end
  end
end
