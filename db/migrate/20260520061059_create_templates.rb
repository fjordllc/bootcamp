class CreateTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :templates do |t|
      t.references :templatable, polymorphic: true, null: false, index: { unique: true }
      t.text :description, null: false

      t.timestamps
    end
  end
end
