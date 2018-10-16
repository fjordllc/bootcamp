# frozen_string_literal: true

class UserSessionsController < ApplicationController
  def new
  end

  def create
    @user = login(params[:user][:login_name], params[:user][:password], params[:remember])

    unless active_user?(@user)
      logout
      flash.now[:alert] = t("invalid_email_or_password")
      return render "new"
    end

    save_updated_at(@user)
    redirect_back_or_to :users, notice: t("sign_in_successful")
  end

  def destroy
    save_updated_at(current_user)
    logout
    redirect_to root_url, notice: t("sign_out")
  end

  private

    def active_user?(user)
      user.present? && !user.retire?
    end

    def save_updated_at(user)
      user.updated_at = Time.current
      user.save!
    end
end
