# frozen_string_literal: true

class API::Users::AreasController < API::BaseController
  def index
    tokyo_area_id = '13'
    @users = Area.users(params[:region], params[:area] || tokyo_area_id)
  end
end
