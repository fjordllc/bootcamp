class CreateBookmarks < ActiveRecord::Migration[6.1]
  def change
    create_table :bookmarks do |t|
      t.references :bookmarkable, polymorphic: true, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
      add_index :bookmarks, [ :bookmarkable_id, :bookmarkable_type, :user_id], unique: true, name: :index_bookmarks_unique
  end
end
