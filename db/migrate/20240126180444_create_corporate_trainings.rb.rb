class CreateCorporateTrainings < ActiveRecord::Migration[6.1]
  def change
    create_table :corporate_trainings do |t|
      t.string :company_name
      t.string :name
      t.string :email
      t.datetime :meeting_date1
      t.datetime :meeting_date2
      t.datetime :meeting_date3
      t.integer :participants_count
      t.string :training_duration
      t.string :how_did_you_hear
      t.text :additional_information
      t.timestamps
    end
  end
end
