class RemovePositionFromPractice < ActiveRecord::Migration[6.1]
  def change
    remove_column :practices, :position, :integer
  end
end
