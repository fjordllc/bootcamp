# frozen_string_literal: true

class API::Users::AreasController < API::BaseController
  def index
    # params[:area]がnilの場合は東京都を取得
    @users = Area.users(params[:area] || '13', params[:region])
  end
end
