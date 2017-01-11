class CreateJoinTablePracticesReports < ActiveRecord::Migration[4.2]
  def change
    create_join_table :practices, :reports do |t|
      t.index [:practice_id, :report_id]
      t.index [:report_id, :practice_id]
    end
  end
end
