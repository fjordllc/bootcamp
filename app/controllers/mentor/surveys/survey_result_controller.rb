# frozen_string_literal: true

class Mentor::Surveys::SurveyResultController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_survey, only: %i[show]

  def show
    @survey_questions = @survey
                        .survey_questions
                        .includes(
                          :linear_scale,
                          radio_button: :radio_button_choices,
                          check_box: :check_box_choices
                        )
    @survey_answers = @survey.survey_answers.includes(survey_question_answers: :survey_question)
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end
end
