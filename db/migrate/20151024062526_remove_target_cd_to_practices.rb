class RemoveTargetCdToPractices < ActiveRecord::Migration
  def change
    remove_column :practices, :target_cd, :string
  end
end
