# frozen_string_literal: true

class Users::QuestionsController < ApplicationController
  before_action :set_user
  before_action :set_questions

  def index; end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_questions
    @questions = user.questions.order(created_at: :desc)
  end

  def user
    @user ||= User.find(params[:user_id])
  end
end
