class CreateSurveys < ActiveRecord::Migration[6.1]
  def change
    create_table :surveys do |t|
      t.references :user, null: false, foreign_key: true
      t.text :title
      t.datetime :expires_at
      t.boolean :wip

      t.timestamps
    end
  end
end
