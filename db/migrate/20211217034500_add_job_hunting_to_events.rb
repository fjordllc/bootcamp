class AddJobHuntingToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :job_hunting, :boolean, default: false, null: false
  end
end
