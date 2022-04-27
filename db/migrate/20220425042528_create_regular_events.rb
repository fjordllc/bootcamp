class CreateRegularEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :regular_events do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.boolean :finished, null: false
      t.boolean :hold_national_holiday, null: false
      t.time :start_at, null: false
      t.time :end_at, null: false
      t.text :wday, null: false

      t.timestamps
    end
  end
end
