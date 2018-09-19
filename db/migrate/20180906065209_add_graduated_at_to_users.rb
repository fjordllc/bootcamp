class AddGraduatedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :graduated_at, :datetime
  end
end
