class CreateFeaturedEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :featured_entries do |t|
      t.references :featureable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
