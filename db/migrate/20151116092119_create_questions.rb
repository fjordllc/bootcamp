class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.text :description
      t.belongs_to :user, index: true
      t.boolean :resolve

      t.timestamps
    end
  end
end
