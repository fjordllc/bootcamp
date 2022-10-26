# frozen_string_literal: true

class SurveyQuestionsController < ApplicationController
  before_action :set_survey_question, only: %i[edit update]

  def index; end

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
    @survey_question.user_id = current_user.id

    if @survey_question.save
      redirect_to survey_questions_path
    else
      render action: :new
    end
  end

  def edit
    @survey_question.user_id = current_user.id
  end

  def update
    if @survey_question.update(survey_question_params)
      redirect_to survey_questions_path
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
                                            radio_button_attributes: %i[id title_of_reason_for_choice description_of_reason_for_choice],
                                            check_box_attributes: %i[id title_of_reason_for_choice description_of_reason_for_choice],
                                            radio_button_choices_attributes: %i[id choices reason_for_choice_required _destroy],
                                            check_box_choices_attributes: %i[id choices reason_for_choice_required _destroy])
  end
end
