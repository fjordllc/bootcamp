class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.belongs_to :practice, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
