# frozen_string_literal: true

class API::Users::RegionsController < API::BaseController
  def index
    # params[:subdivision_or_country]がnilの場合は東京都を取得
    @users = Region.users(params[:subdivision_or_country] || '13', params[:region])
  end
end
