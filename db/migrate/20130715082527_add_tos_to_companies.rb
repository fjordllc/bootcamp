class AddTosToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :tos, :text
  end
end
