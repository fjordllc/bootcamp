# frozen_string_literal: true

class Users::AnswersController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @answers = @user.answers.includes(:question).order(created_at: :desc).page(params[:page])
  end
end
