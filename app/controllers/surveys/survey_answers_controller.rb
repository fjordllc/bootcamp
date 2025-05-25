# frozen_string_literal: true

class Surveys::SurveyAnswersController < ApplicationController
  skip_before_action :require_active_user_login
  before_action :set_survey
  before_action :check_survey_period
  before_action :check_already_answered

  def create
    @survey_answer = SurveyAnswer.new(survey: @survey, user: current_user)

    if @survey_answer.save
      save_question_answers
      redirect_to root_path, notice: 'アンケートに回答しました。'
    else
      @survey_questions = @survey
                          .survey_questions
                          .includes(
                            :linear_scale,
                            radio_button: :radio_button_choices,
                            check_box: :check_box_choices
                          )
      render 'surveys/show'
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:survey_id])
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

  def save_question_answers
    params[:survey_question].each do |question_id, answer_params|
      survey_question = SurveyQuestion.find(question_id)

      case survey_question.format
      when 'radio_button', 'linear_scale'
        save_single_answer(survey_question, answer_params)
      when 'check_box'
        save_multiple_answers(survey_question, answer_params)
      when 'text_area', 'text_field'
        save_text_answer(survey_question, answer_params)
      end
    end
  end

  def save_single_answer(survey_question, answer_params)
    answer = answer_params[:answer]
    reason = get_reason(survey_question, answer_params)

    @survey_answer.survey_question_answers.create(survey_question:, answer:, reason:)
  end

  def save_multiple_answers(survey_question, answer_params)
    answer_params.each do |choice, value|
      next if choice == 'title_of_reason_for_checkbox' || value != '1'

      reason = nil
      if survey_question.check_box.check_box_choices.exists?(choices: choice, reason_for_choice_required: true)
        reason = answer_params[:title_of_reason_for_checkbox]
      end

      answer = choice
      @survey_answer.survey_question_answers.create(survey_question:, answer:, reason:)
    end
  end

  def save_text_answer(survey_question, answer_params)
    @survey_answer.survey_question_answers.create(
      survey_question:,
      answer: answer_params
    )
  end

  def get_reason(survey_question, answer_params)
    case survey_question.format
    when 'radio_button'
      if survey_question.radio_button.radio_button_choices.exists?(choices: answer_params[:answer], reason_for_choice_required: true)
        answer_params[:title_of_reason]
      end
    when 'linear_scale'
      answer_params[:title_of_reason_for_linear_scale] if survey_question.linear_scale.reason_for_choice_required
    end
  end
end
