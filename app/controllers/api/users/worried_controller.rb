# frozen_string_literal: true

class API::Users::WorriedController < API::BaseController
  before_action :require_login
  before_action :require_current_student

  def index
    @worried_users = User.delayed.order(completed_at: :asc)
  end
end
