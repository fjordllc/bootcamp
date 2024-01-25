# frozen_string_literal: true

module TestAuthentication
  extend ActiveSupport::Concern

  def test_login
    return unless params[:_login_name]

    logout if current_user && (current_user.login_name != params[:_login_name])

    login(params[:_login_name], 'testtest')
    login_user = User.find_by(login_name: params[:_login_name])
    session[:user_id] = login_user.id
  end
end
