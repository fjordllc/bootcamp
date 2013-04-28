class AddCompanyIdToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.references :company, default: 1
    end
  end
end
