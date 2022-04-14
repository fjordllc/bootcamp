class AddTrainingEndDateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :training_ends_on, :date
  end
end
