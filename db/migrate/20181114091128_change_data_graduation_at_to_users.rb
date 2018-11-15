# frozen_string_literal: true

class ChangeDataGraduationAtToUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :graduated_at, :date
  end
end
