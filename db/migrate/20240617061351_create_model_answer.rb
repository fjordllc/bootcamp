class CreateModelAnswer < ActiveRecord::Migration[6.1]
  def change
    create_table :model_answers do |t|
      t.references :practice, null: false, foreign_key: true
      t.text :description, null: true

      t.timestamps
    end
  end
end
