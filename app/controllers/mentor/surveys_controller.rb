# frozen_string_literal: true

class Mentor::SurveysController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_survey, only: %i[show edit update destroy]

  def index
    @surveys = Survey.order(end_at: :desc)
  end

  def show
    @survey_questions = @survey
                        .survey_questions
                        .includes(
                          :linear_scale,
                          radio_button: :radio_button_choices,
                          check_box: :check_box_choices
                        )
  end

  def new
    @survey = Survey.new(start_at: Time.current.beginning_of_day, end_at: Time.current.end_of_day.strftime('%Y-%m-%dT-%H:%M'))
    @survey.survey_question_listings.build
  end

  def edit; end

  def create
    @survey = Survey.new(survey_params)
    @survey.user_id = current_user.id
    if @survey.save
      redirect_to mentor_surveys_path, notice: notice_message(@survey)
    else
      render action: :new
    end
  end

  def update
    if @survey.update(survey_params)
      redirect_to mentor_surveys_path, notice: notice_message(@survey)
    else
      render :edit
    end
  end

  def destroy
    @survey.destroy
    redirect_to mentor_surveys_path, notice: 'アンケートを削除しました。'
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(
      :title,
      :start_at,
      :end_at,
      :description,
      survey_question_listings_attributes: %i[id survey_id survey_question_id _destroy]
    )
  end

  def notice_message(survey)
    case params[:action]
    when 'create'
      survey.before_start? ? 'アンケートを受付前として保存しました。' : 'アンケートを作成しました。'
    when 'update'
      survey.before_start? ? 'アンケートを受付前として保存しました。' : 'アンケートを更新しました。'
    end
  end
end
