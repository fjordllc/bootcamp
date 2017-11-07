class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.references :user, foreign_key: true, null: false
      t.references :submission, foreign_key: true, null: false
      t.text :message, null: false

      t.timestamps
    end
  end
end
