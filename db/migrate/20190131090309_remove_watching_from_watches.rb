class RemoveWatchingFromWatches < ActiveRecord::Migration[5.2]
  def change
    remove_column :watches, :watching, :boolean
  end
end
