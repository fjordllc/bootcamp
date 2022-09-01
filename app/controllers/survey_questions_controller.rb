# frozen_string_literal: true

class SurveyQuestionsController < ApplicationController
  before_action :set_survey_question, only: %i[edit update]
  before_action :require_admin_or_mentor_login

  def index
    @survey_questions = SurveyQuestion.all
  end

  def new
    @survey_question = SurveyQuestion.new
    @linear_scale = @survey_question.build_linear_scale
    @radio_button = @survey_question.build_radio_button
    @check_box = @survey_question.build_check_box
    @radio_button_choices = @radio_button.radio_button_choices.build
    @check_box_choices = @check_box.check_box_choices.build
  end

  def create
    @survey_question = SurveyQuestion.new(survey_question_params)
    @survey_question.creator_id = current_user.id
    switch_initialization

    if @survey_question.save
      redirect_to survey_questions_path, notice: '質問を保存しました。'
    else
      render action: :new
    end
  end

  def edit; end

  def update
    @survey_question.updater_id = current_user.id
    switch_initialization
    if @survey_question.update(survey_question_params)
      redirect_to survey_questions_path, notice: '質問を保存しました。'
    else
      render action: :edit
    end
  end

  private

  def set_survey_question
    @survey_question = SurveyQuestion.find(params[:id])
  end

  def survey_question_params
    params.require(:survey_question).permit(:question_title, :question_description, :question_format, :answer_required,
                                            linear_scale_attributes:
                                              %i[id start_of_scale end_of_scale reason_for_choice_required] +
                                              %i[title_of_reason_for_choice description_of_reason_for_choice],
                                            radio_button_attributes:
                                              %i[id title_of_reason_for_choice description_of_reason_for_choice] +
                                              [radio_button_choices_attributes: %i[id choices reason_for_choice_required _destroy]],
                                            check_box_attributes:
                                              %i[id title_of_reason_for_choice description_of_reason_for_choice] +
                                              [check_box_choices_attributes: %i[id choices reason_for_choice_required _destroy]])
  end

  def question_format
    params[:survey_question][:question_format]
  end

  def initialize_radio_button
    @survey_question.radio_button.title_of_reason_for_choice = nil
    @survey_question.radio_button.description_of_reason_for_choice = nil
    @survey_question.radio_button.radio_button_choices.each do |radio_button_choice|
      radio_button_choice.choices = nil
      radio_button_choice.reason_for_choice_required = false
    end
  end

  def initialize_check_box
    @survey_question.check_box.title_of_reason_for_choice = nil
    @survey_question.check_box.description_of_reason_for_choice = nil
    @survey_question.check_box.check_box_choices.each do |check_box_choice|
      check_box_choice.choices = nil
      check_box_choice.reason_for_choice_required = false
    end
  end

  def initialize_linear_scale
    @survey_question.linear_scale.title_of_reason_for_choice = nil
    @survey_question.linear_scale.description_of_reason_for_choice = nil
    @survey_question.linear_scale.start_of_scale = nil
    @survey_question.linear_scale.end_of_scale = nil
    @survey_question.linear_scale.reason_for_choice_required = false
  end

  def switch_initialization
    case question_format
    when 'text_area' || 'text_field'
      initialize_radio_button
      initialize_check_box
      initialize_linear_scale
    when 'radio_button'
      initialize_check_box
      initialize_linear_scale
    when 'check_box'
      initialize_radio_button
      initialize_linear_scale
    end
  end
end
