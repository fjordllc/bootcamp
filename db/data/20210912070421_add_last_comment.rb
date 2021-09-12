# frozen_string_literal: true

class AddLastComment < ActiveRecord::Migration[6.1]
  def up
    Product.add_last_comment_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
