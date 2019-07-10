# frozen_string_literal: true

class API::UsersController < API::BaseController
  def index
    users = User.select(:login_name, :first_name, :last_name)
      .order(updated_at: :desc)
      .as_json(except: :id)
    render json: users
  end

  def show
    @user = User.find(params[:id])
  end
end
