# frozen_string_literal: true

class Mentor::Surveys::SurveyAnswersController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_survey

  def index
    @survey_answers = @survey.survey_answers.includes(:user, survey_question_answers: :survey_question)
  end

  def show
    @survey_answer = @survey.survey_answers.includes(:user, survey_question_answers: :survey_question).find(params[:id])
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end
end
