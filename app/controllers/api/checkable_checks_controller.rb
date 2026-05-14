# frozen_string_literal: true

class API::CheckableChecksController < API::BaseController
  before_action :require_staff
  before_action -> { doorkeeper_authorize! :write }, only: %i[create destroy], if: -> { doorkeeper_token.present? }
  before_action :set_checkable

  def create
    return render json: { message: "この#{@checkable.class.model_name.human}は確認済です。" }, status: :unprocessable_entity if @checkable.checked?

    Check.transaction do
      @check = Check.create!(user: current_user, checkable: @checkable)
      ActiveSupport::Notifications.instrument('check.create', check: @check)
    end
    render json: check_json(@check), status: :created
  end

  def destroy
    check = @checkable.checks.first
    return render json: { message: '確認が見つかりません。' }, status: :not_found unless check

    Check.transaction do
      check.destroy!
      ActiveSupport::Notifications.instrument('check.cancel', check:)
    end
    render json: check_json(check), status: :ok
  end

  private

  def require_staff
    render json: { message: '権限がありません。' }, status: :forbidden unless current_user&.staff?
  end

  def set_checkable
    @checkable = checkable_class.find_by(id: params[:"#{checkable_name}_id"])
    render json: { message: "#{checkable_class.model_name.human}が見つかりません。" }, status: :not_found unless @checkable
  end

  def checkable_class
    raise NotImplementedError
  end

  def checkable_name
    checkable_class.model_name.singular
  end

  def check_json(check)
    {
      id: check.id,
      checkable_type: check.checkable_type,
      checkable_id: check.checkable_id,
      user: {
        id: check.user.id,
        login_name: check.user.login_name,
        name: check.user.name
      },
      created_at: check.created_at
    }
  end
end
