class CreateHibernations < ActiveRecord::Migration[6.1]
  def change
    create_table :hibernations do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.text :reason, null: false
      t.date :scheduled_return_on, null: false
      t.date :returned_at

      t.timestamps
    end
  end
end
