class AddCommentedAtToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :commented_at, :datetime
    add_index :products, :commented_at
  end
end
