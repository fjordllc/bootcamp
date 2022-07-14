# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
    questions =
      case params[:target]
      when 'solved'
        @practice.questions.solved
      when 'not_solved'
        @practice.questions.not_solved.not_wip
      else
        @practice.questions
      end
    @questions = questions
                 .with_avatar
                 .includes(:answers, :tags, :correct_answer)
                 .order(updated_at: :desc, id: :desc)
  end
end
