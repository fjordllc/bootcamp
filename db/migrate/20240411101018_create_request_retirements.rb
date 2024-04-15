class CreateRequestRetirements < ActiveRecord::Migration[6.1]
  def change
    create_table :request_retirements do |t|
      t.string :requester_email, null: false
      t.string :requester_name, null: false
      t.string :requester_company_name, null: false
      t.string :target_user_name, null: false
      t.text :reason_of_request_retirement
      t.boolean :keep_data, null: false, default: true

      t.references :requester, foreign_key: { to_table: :users }
      t.references :target_user, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
