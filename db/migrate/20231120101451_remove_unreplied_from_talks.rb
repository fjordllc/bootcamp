class RemoveUnrepliedFromTalks < ActiveRecord::Migration[6.1]
  def change
    remove_column :talks, :unreplied, :boolean
  end
end
