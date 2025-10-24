# frozen_string_literal: true

class API::BuzzesController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api
  skip_before_action :verify_authenticity_token

  def check
    if Buzz.find_by(url: params[:url])
      render json: { exists: true }
    else
      render json: { exists: false }
    end
  end

  def create
    @buzz = Buzz.find_or_initialize_by(url: params[:buzz][:url])
    if @buzz.new_record?
      @buzz.assign_attributes(buzz_params)
      @buzz.save
      render json: @buzz, status: :created
    else
      @buzz.update(buzz_params)
      render json: @buzz, status: :ok
    end
  end

  private

  def require_admin_or_mentor_login_for_api
    return if current_user.admin_or_mentor?

    render json: { error: '権限がありません' }, status: :forbidden
  end

  def buzz_params
    params.require(:buzz).permit(:title, :published_at, :memo)
  end
end
