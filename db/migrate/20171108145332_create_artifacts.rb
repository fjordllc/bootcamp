class CreateArtifacts < ActiveRecord::Migration[5.1]
  def change
    create_table :artifacts do |t|
      t.references :user, foreign_key: true, null: false
      t.references :practice, foreign_key: true, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
