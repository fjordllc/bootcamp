class AddReferencesToPages < ActiveRecord::Migration[6.0]
  def change
    add_reference :pages, :user, foreign_key: true
  end
end
