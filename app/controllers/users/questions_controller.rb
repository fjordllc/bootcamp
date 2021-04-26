# frozen_string_literal: true

class Users::QuestionsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @questions = @user.questions.order(created_at: :desc)
  end
end
