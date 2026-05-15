class CreateRegularEventParticipations < ActiveRecord::Migration[6.1]
  def change
    create_table :regular_event_participations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :regular_event, null: false, foreign_key: true

      t.timestamps
    end
    add_index :regular_event_participations, %i[user_id regular_event_id], unique: true, name: 'index_user_id_and_regular_event_id'
  end
end
