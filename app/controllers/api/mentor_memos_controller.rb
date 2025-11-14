# frozen_string_literal: true

class Api::MentorMemosController < Api::BaseController
  before_action :require_mentor_login_for_api
  before_action :set_user, only: %i[update]

  def update
    if @user.update_mentor_memo(user_params[:mentor_memo])
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
    params.require(:user).permit(:mentor_memo)
  end
end
