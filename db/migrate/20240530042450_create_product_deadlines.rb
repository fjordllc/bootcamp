class CreateProductDeadlines < ActiveRecord::Migration[6.1]
  def change
    create_table :product_deadlines do |t|
      t.integer :alert_day, default: 4

      t.timestamps
    end
  end
end
