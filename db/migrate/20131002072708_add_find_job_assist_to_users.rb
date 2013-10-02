class AddFindJobAssistToUsers < ActiveRecord::Migration
  def change
    add_column :users, :find_job_assist, :boolean, null: false, default: false
  end
end
