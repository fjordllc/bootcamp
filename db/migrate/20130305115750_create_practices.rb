class CreatePractices < ActiveRecord::Migration[4.2]
  def change
    create_table :practices do |t|
      t.string :title, null: false, limit: 255
      t.text :description, null: true

      t.timestamps
    end
  end
end
