class CreateRequestRetirements < ActiveRecord::Migration[6.1]
  def change
    create_table :request_retirements , id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :user
      t.references :target_user, index: { unique: true }, foreign_key: { to_table: :users }
      t.string :company_name, null: false
      t.text :reason
      t.boolean :keep_data, null: false, default: true

      t.timestamps
    end
  end
end
