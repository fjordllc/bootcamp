class AddIndexToPairWorksPublishedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :pair_works, :published_at, if_not_exists: true
  end
end
