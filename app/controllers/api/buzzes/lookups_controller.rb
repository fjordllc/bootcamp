# frozen_string_literal: true

class API::Buzzes::LookupsController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api
  skip_before_action :verify_authenticity_token

  def show
    return render json: { error: 'URLパラメータが必要です' }, status: :bad_request if params[:url].blank?

    @buzz = Buzz.find_by(url: params[:url])
    if @buzz
      render json: @buzz
    else
      head :not_found
    end
  end
end
