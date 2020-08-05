# frozen_string_literal: true

class AddWipToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :wip, :boolean, null: false, default: false
  end
end
