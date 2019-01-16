# frozen_string_literal: true

class Users::RetirementsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
  end

  def new
    @user = User.new
  end
end
