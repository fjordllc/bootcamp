# frozen_string_literal: true

class Mentor::Practices::PracticeQuiz::QuestionsController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_practice
  before_action :set_practice_quiz
  before_action :set_question, only: %i[edit update destroy]

  def new
    @question = @practice_quiz.practice_quiz_questions.build(position: next_position)
    (1..4).each do |index|
      @question.practice_quiz_choices.build(position: index)
    end
  end

  def edit
    (4 - @question.practice_quiz_choices.size).times do
      @question.practice_quiz_choices.build(position: @question.practice_quiz_choices.size + 1)
    end
  end

  def create
    @question = @practice_quiz.practice_quiz_questions.build(question_params)
    if @question.save
      redirect_to edit_mentor_practice_practice_quiz_path(@practice), notice: '問題を作成しました。'
    else
      render :new
    end
  end

  def update
    if @question.update(question_params)
      redirect_to edit_mentor_practice_practice_quiz_path(@practice), notice: '問題を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    if @question.destroy
      redirect_to edit_mentor_practice_practice_quiz_path(@practice), notice: '問題を削除しました。'
    else
      redirect_to edit_mentor_practice_practice_quiz_path(@practice), alert: @question.errors.full_messages.join(', ')
    end
  end

  private

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end

  def set_practice_quiz
    @practice_quiz = @practice.practice_quiz
    redirect_to new_mentor_practice_practice_quiz_path(@practice) if @practice_quiz.blank?
  end

  def set_question
    @question = @practice_quiz.practice_quiz_questions.find(params[:id])
  end

  def next_position
    @practice_quiz.practice_quiz_questions.maximum(:position).to_i + 1
  end

  def question_params
    params.require(:practice_quiz_question).permit(
      :question_type,
      :body,
      :explanation,
      :position,
      :published,
      practice_quiz_choices_attributes: %i[id body correct position _destroy]
    )
  end
end
