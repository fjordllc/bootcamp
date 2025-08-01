class CreatePairWorks < ActiveRecord::Migration[6.1]
  def change
    create_table :pair_works do |t|
      t.string :title, null: false
      t.text :description
      t.timestamp :reserved_at
      t.references :user, null: false, foreign_key: true
      t.references :practice, foreign_key: true
      t.references :buddy, foreign_key: { to_table: :users }
      t.timestamp :published_at
      t.boolean :wip, null: false

      t.timestamps
    end
  end
end
