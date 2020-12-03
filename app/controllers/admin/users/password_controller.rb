# frozen_string_literal: true

class Admin::Users::PasswordController < AdminController
  before_action :set_user

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "パスワードを更新しました。"
    else
      render "edit"
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
    @user = User.find(params[:user_id])
  end
end
