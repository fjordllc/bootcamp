class AddInvoicePaymentToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :invoice_payment, :boolean, default: false, null: false
  end
end
