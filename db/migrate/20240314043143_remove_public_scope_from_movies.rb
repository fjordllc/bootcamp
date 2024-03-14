class RemovePublicScopeFromMovies < ActiveRecord::Migration[6.1]
  def change
    remove_column :movies, :public_scope, :boolean
  end
end
