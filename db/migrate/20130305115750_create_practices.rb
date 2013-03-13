class CreatePractices < ActiveRecord::Migration
  def change
    create_table :practices do |t|
      t.string :title, :null => false, :limit => 255
      t.text :draft
      t.text :description, :null => true

      t.timestamps
    end
  end
end
