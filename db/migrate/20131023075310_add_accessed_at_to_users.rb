# frozen_string_literal: true

class AddAccessedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :accessed_at, :datetime
  end
end
