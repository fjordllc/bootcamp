# frozen_string_literal: true

module APIHelper
  def create_token(login_name, password)
    post api_session_url, params: { login_name: login_name, password: password }
    JSON.parse(body)['token']
  end
end
