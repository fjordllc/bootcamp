# frozen_string_literal: true

class AddWipToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :wip, :boolean, null: false, default: false
  end
end
