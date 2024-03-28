class AddMemoToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :memo, :text
  end
end
