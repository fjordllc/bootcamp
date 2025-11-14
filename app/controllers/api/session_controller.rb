# frozen_string_literal: true

class Api::SessionController < Api::BaseController
  protect_from_forgery except: %i[create]
  skip_before_action :require_login_for_api, only: %i[create]

  def create
    logout if current_user
    user = User.authenticate(params[:login_name], params[:password])
    if user
      token = User.issue_token(id: user.id, email: user.email)
      render json: { token: }
    else
      head :bad_request
    end
  end
end
