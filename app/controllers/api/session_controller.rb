# frozen_string_literal: true

class API::SessionController < API::BaseController
  protect_from_forgery except: %i(create)
  skip_before_action :require_login, only: %i(create)

  def create
    token = login_and_issue_token(params[:login_name], params[:password])
    if token
      render json: { token: token }
    else
      head :bad_request
    end
  end
end
