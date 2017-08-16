class CreateFootprints < ActiveRecord::Migration[5.0]
  def change
    create_table :footprints do |t|
      t.integer :user_id
      t.integer :report_id

      t.timestamps
    end
    add_index :footprints, :user_id
    add_index :footprints, :report_id
    add_index :footprints, [:user_id, :report_id], unique: true
  end
end
