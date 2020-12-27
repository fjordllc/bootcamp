# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :require_mentor_login_for_api, only: %i[update]

  def index
    users = User.select(:login_name, :name)
                .order(updated_at: :desc)
                .as_json(except: :id)
    render json: users
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_user_mentor_memo(@user.id, user_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def user_params
    params.require(:user).permit(:memo)
  end
end
