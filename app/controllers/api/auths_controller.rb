# frozen_string_literal: true

class API::AuthsController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api
  skip_before_action :verify_authenticity_token

  def show
    head :ok
  end
end
