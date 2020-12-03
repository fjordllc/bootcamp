# frozen_string_literal: true

class ChangeDataGraduationAtToUsers < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :graduated_at, :date
  end

  def down
    change_column :users, :graduated_at, :datetime
  end
end
