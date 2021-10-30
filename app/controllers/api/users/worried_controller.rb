# frozen_string_literal: true

class API::Users::WorriedController < API::BaseController
  before_action :require_login

  def index
    @worried_users = User.delayed.order(completed_at: :asc)
  end
end
