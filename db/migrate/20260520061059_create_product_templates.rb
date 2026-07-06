class CreateProductTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :product_templates do |t|
      t.references :practice, null: false, foreign_key: true, index: { unique: true }
      t.text :description, null: false

      t.timestamps
    end
  end
end
