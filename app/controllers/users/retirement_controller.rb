# frozen_string_literal: true

class Users::RetirementController < ApplicationController
  def new
    @user = User.find(params[:user_id])
  end

  def show
  end
end
