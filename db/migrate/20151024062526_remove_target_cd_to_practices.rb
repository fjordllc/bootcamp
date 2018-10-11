# frozen_string_literal: true

class RemoveTargetCdToPractices < ActiveRecord::Migration[4.2]
  def change
    remove_column :practices, :target_cd, :string
  end
end
