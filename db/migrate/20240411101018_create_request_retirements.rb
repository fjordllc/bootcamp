class CreateRequestRetirements < ActiveRecord::Migration[6.1]
  def change
    create_table :request_retirements do |t|
      t.references :user, foreign_key: true
      t.references :target_user, index: { unique: true }, foreign_key: { to_table: :users }
      t.text :reason
      t.boolean :keep_data, null: false, default: true

      t.timestamps
    end
  end
end
