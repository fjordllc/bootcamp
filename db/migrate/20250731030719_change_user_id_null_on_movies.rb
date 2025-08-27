class ChangeUserIdNullOnMovies < ActiveRecord::Migration[6.1]
  def change
    change_column_null :movies, :user_id, true
  end
end
