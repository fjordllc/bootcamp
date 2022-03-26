# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
    questions =
      if params[:solved].present?
        @practice.questions.solved
      elsif params[:not_solved].present?
        @practice.questions.not_solved
      else
        @practice.questions
      end
    @questions = questions
                 .with_avatar
                 .includes(:answers, :tags, :correct_answer, user: :company)
                 .order(updated_at: :desc, id: :desc)
  end
end
