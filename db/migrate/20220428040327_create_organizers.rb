class CreateOrganizers < ActiveRecord::Migration[6.1]
  def change
    create_table :organizers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :regular_event, null: false, foreign_key: true

      t.timestamps
    end
    add_index :organizers, %i[user_id regular_event_id], unique: true
  end
end
