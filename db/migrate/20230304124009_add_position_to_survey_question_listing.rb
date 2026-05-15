class AddPositionToSurveyQuestionListing < ActiveRecord::Migration[6.1]
  def change
    add_column :survey_question_listings, :position, :integer
  end
end
