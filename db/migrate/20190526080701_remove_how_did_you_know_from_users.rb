# frozen_string_literal: true

class RemoveHowDidYouKnowFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :how_did_you_know, :string
  end
end
