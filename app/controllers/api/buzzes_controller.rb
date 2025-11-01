# frozen_string_literal: true

class API::BuzzesController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api
  skip_before_action :verify_authenticity_token

  def check
    return render json: { error: 'URLパラメータが必要です' }, status: :bad_request if params[:url].blank?

    if Buzz.find_by(url: params[:url])
      render json: { exists: true }
    else
      render json: { exists: false }
    end
  end

  def create
    return render json: { error: 'パラメータが不正です' }, status: :bad_request unless params[:buzz].present? && params[:buzz][:url].present?

    @buzz = Buzz.find_or_initialize_by(url: buzz_params[:url])
    if @buzz.new_record?
      @buzz.assign_attributes(buzz_params)
      if @buzz.save
        render json: @buzz, status: :created
      else
        render json: { errors: @buzz.errors.full_messages }, status: :unprocessable_entity
      end
    elsif @buzz.update(buzz_params)
      render json: @buzz, status: :ok
    else
      render json: { errors: @buzz.errors.full_message }, status: :unprocessable_entity
    end
  end

  private

  def require_admin_or_mentor_login_for_api
    return if current_user.admin_or_mentor?

    render json: { error: '権限がありません' }, status: :forbidden
  end

  def buzz_params
    params.require(:buzz).permit(:title, :url, :published_at, :memo)
  end
end
