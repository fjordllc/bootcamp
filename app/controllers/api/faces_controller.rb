class API::FacesController < API::BaseController
  def index
    @users = User.working
  end
end
