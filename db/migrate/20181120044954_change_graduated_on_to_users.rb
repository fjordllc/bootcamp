# frozen_string_literal: true

class ChangeGraduatedOnToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :graduated_at, :graduated_on
  end
end
