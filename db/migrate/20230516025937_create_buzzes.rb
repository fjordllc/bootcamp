class CreateBuzzes < ActiveRecord::Migration[6.1]
  def change
    create_table :buzzes do |t|
      t.text :body

      t.timestamps
    end
  end
end
