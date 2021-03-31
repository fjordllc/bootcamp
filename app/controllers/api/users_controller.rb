# frozen_string_literal: true

class API::UsersController < API::BaseController
  before_action :set_page, only: %i[update]
  before_action :require_login

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
    if @user.update(user_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_page
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:tag_list)
  end
end
