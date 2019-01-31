class CreateWatches < ActiveRecord::Migration[5.2]
  def change
    create_table :watches do |t|
      t.references :watchable, polymorphic: true, index: true
      t.boolean :watching

      t.timestamps
    end
  end
end
