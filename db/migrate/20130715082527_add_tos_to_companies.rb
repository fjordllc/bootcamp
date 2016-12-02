class AddTosToCompanies < ActiveRecord::Migration[4.2]
  def change
    add_column :companies, :tos, :text
  end
end
