class AddColumnsToInquiries < ActiveRecord::Migration[7.2]
  def change
    add_reference :inquiries, :completed_by_user, foreign_key: { to_table: :users, on_delete: :nullify }
    add_column :inquiries, :completed_at, :datetime
  end
end
