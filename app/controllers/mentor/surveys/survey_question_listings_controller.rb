# frozen_string_literal: true

class Mentor::Surveys::SurveyQuestionListingsController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_survey

  def index
    @survey_question_listings = @survey.survey_question_listings.includes(:survey_question).order(:position)
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end
end
