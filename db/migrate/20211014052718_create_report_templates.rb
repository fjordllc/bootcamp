class CreateReportTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :report_templates do |t|
      t.references :user, foreign_key: true
      t.text :description, null: true
      t.timestamps
    end
  end
end
