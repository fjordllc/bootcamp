# frozen_string_literal: true

class Surveys::SurveyQuestionListingsController < ApplicationController
  before_action :require_admin_or_mentor_login

  def index
    @survey = Survey.find(params[:survey_id])
    @survey_question_listings = @survey.survey_question_listings
  end
end
