class AddUnrepliedToTalks < ActiveRecord::Migration[6.1]
  def change
    add_column :talks, :unreplied, :boolean, default: false, null: false
  end
end
