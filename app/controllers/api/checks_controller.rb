# frozen_string_literal: true

class API::ChecksController < API::BaseController
  CHECKABLE_CLASSES = {
    'Product' => Product,
    'Report' => Report
  }.freeze

  before_action :require_staff_login_for_api, only: %i[create destroy]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create destroy], if: -> { doorkeeper_token.present? }
  before_action -> { doorkeeper_authorize! :mentor }, only: %i[create destroy], if: -> { doorkeeper_token.present? }
  before_action :validate_checkable_type, only: %i[index create]

  def index
    @checks = Check.where(
      checkable:
    )
  end

  def create
    if checkable.checks.empty?
      begin
        Check.transaction do
          @check = Check.create!(user: current_user, checkable:)
          ActiveSupport::Notifications.instrument('check.create', check: @check)
        end
        render json: check_json(@check), status: :created
      rescue StandardError => e
        Rails.logger.error("[API::ChecksController#create] チェック作成でエラー: #{e.message}")
        render json: { message: 'エラーが発生しました。' }, status: :internal_server_error
      end
    else
      render json: { message: "この#{checkable.class.model_name.human}は確認済です。" }, status: :unprocessable_entity
    end
  end

  def destroy
    Check.transaction do
      @check = Check.find(params[:id]).destroy!
      ActiveSupport::Notifications.instrument('check.cancel', check: @check)
    end
    render json: { id: @check.id }, status: :ok
  rescue StandardError => e
    Rails.logger.error("[API::ChecksController#destroy] チェック削除でエラー: #{e.message}")
    render json: { message: 'エラーが発生しました。' }, status: :internal_server_error
  end

  private

  def validate_checkable_type
    type = params[:checkable_type]
    head :bad_request unless type.is_a?(String) && CHECKABLE_CLASSES.key?(type)
  end

  def checkable
    CHECKABLE_CLASSES.fetch(params[:checkable_type]).find_by(id: params[:checkable_id])
  end
end
