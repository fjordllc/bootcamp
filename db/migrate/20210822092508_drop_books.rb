class DropBooks < ActiveRecord::Migration[6.1]
  def change
    drop_table :books do |t|
      t.string :title, null: false
      t.string :isbn, null: false
      t.boolean :borrowed, default: false, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
