class CreateRelatedBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :related_books do |t|
      t.string :title
      t.string :url
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
