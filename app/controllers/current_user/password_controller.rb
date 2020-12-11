# frozen_string_literal: true

class CurrentUser::PasswordController < ApplicationController
  before_action :require_login
  before_action :set_user

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'パスワードを更新しました。'
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :password,
      :password_confirmation
    )
  end

  def set_user
    @user = current_user
  end
end
