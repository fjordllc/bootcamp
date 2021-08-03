# frozen_string_literal: true

class API::UserTagsController < API::BaseController
  before_action :set_user, only: %i[update]
  before_action :require_login_for_api

  def update
    if @user == current_user && @user.update(user_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:tag_list)
  end
end
