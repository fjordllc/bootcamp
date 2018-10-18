# frozen_string_literal: true

class UserSessionsController < ApplicationController
  def new
  end

  def create
    @user = login(params[:user][:login_name], params[:user][:password], params[:remember])
    if @user && !@user.retire?
      save_updated_at(@user)
      redirect_back_or_to :users, notice: t("sign_in_successful")
    else
      logout
      flash.now[:alert] = t("invalid_email_or_password")
      render "new"
    end
  end

  def destroy
    save_updated_at(current_user)
    logout
    redirect_to root_url, notice: t("sign_out")
  end

  private
    def save_updated_at(user)
      user.updated_at = Time.current
      user.save!
    end
end
