# frozen_string_literal: true

class AddCheckerIdToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :checker_id, :bigint
  end
end
