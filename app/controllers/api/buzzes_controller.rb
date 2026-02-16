# frozen_string_literal: true

class API::BuzzesController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api
  skip_before_action :verify_authenticity_token

  def show
    return render json: { error: 'URLパラメータが必要です' }, status: :bad_request if params[:url].blank?

    @buzz = Buzz.find_by(url: params[:url])
    if @buzz
      render json: @buzz, status: :ok
    else
      head :not_found
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
      render json: { errors: @buzz.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @buzz = set_buzz
    if @buzz
      @buzz.destroy
      render json: @buzz, status: :ok
    else
      render json: { error: 'Buzzが見つかりません' }, status: :not_found
    end
  end

  private

  def set_buzz
    Buzz.find_by(url: params[:url])
  end

  def buzz_params
    params.require(:buzz).permit(:title, :url, :published_at, :memo)
  end
end
