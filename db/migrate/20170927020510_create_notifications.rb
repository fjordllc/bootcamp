class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.integer :kind, null: false, default: 0
      t.references :user, foreign_key: true
      t.integer :sender_id, null: false
      t.string :message
      t.string :path
      t.boolean :read, default: false, null: false

      t.timestamps
    end
    add_foreign_key :notifications, :users, column: :sender_id
  end
end
