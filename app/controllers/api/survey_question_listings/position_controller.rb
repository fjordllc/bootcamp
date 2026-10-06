# frozen_string_literal: true

class API::SurveyQuestionListings::PositionController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api, only: :update
  before_action -> { doorkeeper_authorize! :write }, only: :update, if: -> { doorkeeper_token.present? }

  def update
    @survey_question_listing = SurveyQuestionListing.find(params[:survey_question_listing_id])
    if @survey_question_listing.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @survey_question_listing.errors, status: :unprocessable_entity
    end
  end
end
