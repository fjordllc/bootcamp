# frozen_string_literal: true

class AddOpinionToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :opinion, :text
  end
end
