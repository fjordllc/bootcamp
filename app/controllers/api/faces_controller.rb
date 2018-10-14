# frozen_string_literal: true

class API::FacesController < API::BaseController
  def index
    @users = User.working
  end
end
