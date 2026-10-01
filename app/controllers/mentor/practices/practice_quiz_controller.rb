# frozen_string_literal: true

class Mentor::Practices::PracticeQuizController < ApplicationController
  before_action :require_admin_or_mentor_login
  before_action :set_practice
  before_action :set_practice_quiz, only: %i[show edit update destroy]

  def show
    redirect_to edit_mentor_practice_practice_quiz_path(@practice)
  end

  def new
    if @practice.practice_quiz.present?
      redirect_to edit_mentor_practice_practice_quiz_path(@practice)
      return
    end

    @practice_quiz = @practice.build_practice_quiz
  end

  def edit; end

  def create
    @practice_quiz = @practice.build_practice_quiz(practice_quiz_params)
    if @practice_quiz.save
      redirect_to edit_mentor_practice_practice_quiz_path(@practice), notice: '理解度テストを作成しました。'
    else
      render :new
    end
  end

  def update
    if @practice_quiz.update(practice_quiz_params)
      redirect_to edit_mentor_practice_practice_quiz_path(@practice), notice: '理解度テストを更新しました。'
    else
      render :edit
    end
  end

  def destroy
    @practice_quiz.destroy!
    redirect_to mentor_practices_path, notice: '理解度テストを削除しました。'
  end

  private

  def set_practice
    @practice = Practice.find(params[:practice_id])
  end

  def set_practice_quiz
    @practice_quiz = @practice.practice_quiz
    redirect_to new_mentor_practice_practice_quiz_path(@practice) if @practice_quiz.blank?
  end

  def practice_quiz_params
    params.require(:practice_quiz).permit(:published)
  end
end
