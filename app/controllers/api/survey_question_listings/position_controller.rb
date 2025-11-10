# frozen_string_literal: true

class Api::SurveyQuestionListings::PositionController < Api::BaseController
  def update
    @survey_question_listing = SurveyQuestionListing.find(params[:survey_question_listing_id])
    if @survey_question_listing.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @survey_question_listing.errors, status: :unprocessable_entity
    end
  end
end
