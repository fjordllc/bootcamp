# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_login_for_api, only: %i[index show]
  before_action -> { doorkeeper_authorize! :write }, only: %i[create update destroy], if: -> { doorkeeper_token.present? }
  before_action :set_product, only: %i[update destroy]

  def index
    @company = Company.find(params[:company_id]) if params[:company_id]
    per = params[:per] || 50
    @products = Product
                .list
                .order_for_all_list
                .page(params[:page])
                .per(per)
    @products_grouped_by_elapsed_days = @products.group_by(&:elapsed_days)
    @products = @products.joins(:user).where(users: { company_id: params[:company_id] }) if params[:company_id]
    @products = @products.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def show
    @product = Product.find(params[:id])
  end

  def create
    @product = current_user.products.new(product_attributes)
    @product.practice = Practice.find_by(id: product_params[:practice_id])
    apply_wip
    update_published_at

    if @product.save
      ActiveSupport::Notifications.instrument('product.create', product: @product)
      ActiveSupport::Notifications.instrument('product.save', product: @product)
      render_product_json :created
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end

  def update
    @product.assign_attributes(product_attributes)
    apply_wip
    update_published_at

    if @product.save
      ActiveSupport::Notifications.instrument('product.update', { product: @product, current_user: })
      ActiveSupport::Notifications.instrument('product.save', product: @product)
      render_product_json :ok
    else
      render json: { errors: @product.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find_by(id: params[:id])
    return render json: { message: '提出物が見つかりません。' }, status: :not_found unless @product
    return if current_user.admin? || current_user.mentor? || @product.user == current_user

    render json: { message: 'この提出物を操作する権限がありません。' }, status: :forbidden
  end

  def product_params
    params.fetch(:product, ActionController::Parameters.new).permit(:practice_id, :body, :wip)
  end

  def product_attributes
    product_params.except(:practice_id, :wip)
  end

  def apply_wip
    return unless product_params.key?(:wip)

    @product.wip = ActiveModel::Type::Boolean.new.cast(product_params[:wip])
  end

  def update_published_at
    if @product.wip
      @product.published_at = nil
    elsif @product.published_at.blank?
      @product.published_at = Time.current
    end
  end

  def render_product_json(status)
    render json: {
      id: @product.id,
      practice_id: @product.practice_id,
      body: @product.body,
      wip: @product.wip,
      published_at: @product.published_at
    }, status:
  end
end
