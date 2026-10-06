# frozen_string_literal: true

class API::SessionController < API::BaseController
  protect_from_forgery except: %i[create]
  skip_before_action :require_login_for_api, only: %i[create]
  skip_before_action :deny_inactive_user_for_api, only: %i[create]

  rate_limit to: 100, within: 3.minutes, only: :create, name: 'ip', scope: 'login', with: -> { head :too_many_requests }
  rate_limit to: 10, within: 3.minutes, only: :create, name: 'account', scope: 'login',
             by: :login_rate_limit_identity, with: -> { head :too_many_requests }

  def create
    logout if current_user
    user = User.authenticate(params[:login_name], params[:password])
    if user && !user.inactive?
      token = User.issue_token(id: user.id, email: user.email)
      render json: { token: }
    else
      head :bad_request
    end
  end

  private

  def login_rate_limit_identity
    login = params[:login_name]
    Digest::SHA256.hexdigest(login.is_a?(String) ? login.strip.downcase : '')
  end
end
