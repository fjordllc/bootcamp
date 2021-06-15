# frozen_string_literal: true

class Users::QuestionsController < ApplicationController
  before_action :require_login

  def index
    @user = User.find(params[:user_id])
    @questions = @user.questions.order(created_at: :desc)
  end
end
