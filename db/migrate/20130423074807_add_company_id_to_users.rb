class AddCompanyIdToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.references :company, default: 1
    end
  end
end
