class AddReadFlagToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :read_flag, :integer
  end
end
