# frozen_string_literal: true

class Users::AnswersController < ApplicationController
  def index
    @user = User.find(params[:user_id])
  end
end
