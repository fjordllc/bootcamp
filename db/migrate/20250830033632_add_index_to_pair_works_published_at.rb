class AddIndexToPairWorksPublishedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :pair_works, :published_at
  end
end
