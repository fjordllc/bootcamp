class RemoveMemos < ActiveRecord::Migration[6.1]
  def change
    drop_table :memos do |t|
      t.date :date
      t.string :body
      t.index  :memos, :date, unique: true
      t.timestamps
    end
  end
end
