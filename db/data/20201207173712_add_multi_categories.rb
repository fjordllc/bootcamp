# frozen_string_literal: true

class AddMultiCategories < ActiveRecord::Migration[6.0]
  def up
    sql = "INSERT INTO categories_practices (category_id, practice_id) SELECT practices.category_id, practices.id FROM practices ORDER BY practices.category_id, practices.id"
    ActiveRecord::Base.connection.execute sql
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
