class ChangeCorporateTrainingsToCorporateTrainingInquiries < ActiveRecord::Migration[6.1]
  def change
    rename_table :corporate_trainings, :corporate_training_inquiries
  end
end
