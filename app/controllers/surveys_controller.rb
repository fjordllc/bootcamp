# frozen_string_literal: true

class SurveysController < ApplicationController
  skip_before_action :require_active_user_login
  before_action :set_survey, only: %i[show]
  # before_action :check_survey_period, only: %i[show]
  before_action :check_already_answered, only: %i[show]

  def show
    @survey_questions = @survey
                        .survey_questions
                        .includes(
                          :linear_scale,
                          radio_button: :radio_button_choices,
                          check_box: :check_box_choices
                        )
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def check_survey_period
    if @survey.before_start?
      redirect_to root_path, alert: 'このアンケートはまだ回答期間ではありません。'
    elsif @survey.answer_ended?
      redirect_to root_path, alert: 'このアンケートの回答期間は終了しました。'
    end
  end

  def check_already_answered
    return unless SurveyAnswer.exists?(survey: @survey, user: current_user)

    redirect_to root_path, alert: 'このアンケートには既に回答済みです。'
  end
end
