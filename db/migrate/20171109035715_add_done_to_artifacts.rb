class AddDoneToArtifacts < ActiveRecord::Migration[5.1]
  def change
    add_column :artifacts, :done, :boolean, default: false, null: false
  end
end
