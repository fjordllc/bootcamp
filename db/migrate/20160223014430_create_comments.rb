class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :description
      t.references :user, index: true
      t.references :report, index: true

      t.timestamps
    end
  end
end
