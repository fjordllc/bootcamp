# frozen_string_literal: true

class AddLastUpdatedUserToPractices < ActiveRecord::Migration[6.0]
  def change
    add_column :practices, :last_updated_user_id, :integer
  end
end
