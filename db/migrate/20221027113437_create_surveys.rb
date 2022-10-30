class CreateSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :surveys do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, limit: 255
      t.text :description
      t.datetime :published_at, null: false
      t.datetime :expires_at, null: false
      t.boolean :wip, null: false, default: false

      t.timestamps
    end
  end
end
