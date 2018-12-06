# frozen_string_literal: true

class AddIndexToPages < ActiveRecord::Migration[5.2]
  def change
    add_index :pages, :updated_at
  end
end
