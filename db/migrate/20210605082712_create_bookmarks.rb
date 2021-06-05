class CreateBookmarks < ActiveRecord::Migration[6.1]
  def change
    create_table :bookmarks do |t|
      t.references :bookmarkable, polymorphic: true, null: false
      t.integer :user_id

      t.timestamps
    end
  end
end
