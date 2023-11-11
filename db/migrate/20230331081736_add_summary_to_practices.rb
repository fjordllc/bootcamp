class AddSummaryToPractices < ActiveRecord::Migration[6.1]
  def change
    add_column :practices, :summary, :text
  end
end
