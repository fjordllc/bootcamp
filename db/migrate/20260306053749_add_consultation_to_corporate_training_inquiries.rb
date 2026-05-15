class AddConsultationToCorporateTrainingInquiries < ActiveRecord::Migration[8.1]
  def change
    add_column :corporate_training_inquiries, :consultation, :boolean, default: false, null: false
  end
end
