# frozen_string_literal: true

class Practices::QuestionsController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
    questions = @practice.questions
    @questions = questions
                 .with_avatar
                 .includes(:answers, :tags, :correct_answer, user: :company)
                 .order(updated_at: :desc, id: :desc)
  end
end
