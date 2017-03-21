class AddPurposeToContact < ActiveRecord::Migration[5.0]
  def change
    add_column :contacts, :purpose_content, :string, null: false
    add_column :contacts, :purpose_deadline_year, :integer, null: false
    add_column :contacts, :purpose_deadline_month, :integer, null: false
  end
end
