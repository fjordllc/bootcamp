# frozen_string_literal: true

class Users::TalksController < ApplicationController
  def show
    @user = User.find(params[:user_id])
    @works = @user.talk
  end
end
