# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :set_survey, only: %i[show edit update destroy]
  before_action :require_admin_or_mentor_login

  # GET /surveys or /surveys.json
  def index
    @surveys = Survey.all.order(end_at: :desc)
  end

  # GET /surveys/1 or /surveys/1.json
  def show; end

  # GET /surveys/new
  def new
    @survey = Survey.new(start_at: Time.current.beginning_of_day, end_at: Time.current.end_of_day.strftime('%Y-%m-%dT-%H:%M'))
    @survey.survey_question_listings.build
  end

  # GET /surveys/1/edit
  def edit; end

  # POST /surveys or /surveys.json
  def create
    @survey = Survey.new(survey_params)
    @survey.user_id = current_user.id
    if @survey.save
      redirect_to surveys_path, notice: notice_message(@survey)
    else
      render action: :new
    end
  end

  # PATCH/PUT /surveys/1 or /surveys/1.json
  def update
    if @survey.update(survey_params)
      redirect_to surveys_path, notice: notice_message(@survey)
    else
      render :edit
    end
  end

  # DELETE /surveys/1 or /surveys/1.json
  def destroy
    @survey.destroy
    redirect_to surveys_path, notice: 'アンケートを削除しました。'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey
    @survey = Survey.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def survey_params
    params.require(:survey).permit(
      :title,
      :start_at,
      :end_at,
      :description,
      survey_question_ids: [],
      survey_question_listings_attributes: %i[id survey_question_id _destroy]
    )
  end

  def notice_message(survey)
    case params[:action]
    when 'create'
      survey.before_start?(survey.id) ? 'アンケートを受付前として保存しました。' : 'アンケートを作成しました。'
    when 'update'
      survey.before_start?(survey.id) ? 'アンケートを受付前として保存しました。' : 'アンケートを更新しました。'
    end
  end
end
