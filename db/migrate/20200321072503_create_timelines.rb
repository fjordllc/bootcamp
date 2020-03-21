class CreateTimelines < ActiveRecord::Migration[6.0]
  def change
    create_table :timelines do |t|
      t.references :user, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
