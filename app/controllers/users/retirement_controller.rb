# frozen_string_literal: true

class Users::RetirementController < ApplicationController
  def show
  end

  def new
    @user = User.find(params[:user_id])
  end

  def create
    @user = User.find(params[:user_id])
    @user.assign_attributes(retire_reason_params)
    @user.retired_on = Date.current
    if @user.save(context: :retire_reason_presence)
      logout
      redirect_to user_retirement_url(@user)
    else
      render :new
    end
  end

  private
    def retire_reason_params
      params.require(:user).permit(:retire_reason)
    end
end
