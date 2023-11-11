# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :check_permission!, only: %i[show]
  before_action :require_staff_login, only: :index
  before_action :set_watch, only: %i[show]

  def index; end

  def show
    @product = find_product
    @products = @product.user
                        .products
                        .not_wip
                        .order(published_at: :DESC)
    @practice = find_practice
    @learning = @product.learning # decoratorメソッド用にcontrollerでインスタンス変数化
    @tweet_url = @practice.tweet_url(practice_completion_url(@practice.id))
    respond_to do |format|
      format.html
      format.md
    end
  end

  def new
    @practice = find_practice
    @product = @practice.products.new(user: current_user)
  end

  def edit
    @product = find_my_product
    @practice = @product.practice
  end

  def create
    @product = Product.new(product_params)
    @practice = find_practice
    @product.practice = @practice
    @product.user = current_user
    set_wip
    update_published_at
    if @product.save
      Newspaper.publish(:product_create, @product)
      Newspaper.publish(:product_save, @product)
      redirect_to Redirection.determin_url(self, @product), notice: notice_message(@product, :create)
    else
      render :new
    end
  end

  def update
    @product = find_my_product
    @practice = @product.practice
    @product.published_at = nil if @product.published_at? && @product.wip
    set_wip
    update_published_at
    if @product.update(product_params)
      Newspaper.publish(:product_update, { product: @product, current_user: current_user })
      Newspaper.publish(:product_save, @product)
      notice_another_mentor_assigned_as_checker
      redirect_to Redirection.determin_url(self, @product), notice: notice_message(@product, :update)
    else
      render :edit
    end
  end

  def destroy
    @product = find_my_product
    @product.destroy
    redirect_to @product.practice, notice: '提出物を削除しました。'
  end

  private

  def update_published_at
    return if @product.wip || @product.published_at?

    @product.published_at = Time.current
  end

  def find_product
    Product.find(params[:id])
  end

  def find_practice
    if params[:practice_id]
      Practice.find(params[:practice_id])
    else
      find_product.practice
    end
  end

  def find_my_product
    if admin_or_mentor_login?
      Product.find(params[:id])
    else
      current_user.products.find(params[:id])
    end
  end

  def check_permission!
    return if policy(find_product).show? || find_practice&.open_product?

    redirect_to root_path, alert: 'プラクティスを修了するまで他の人の提出物は見れません。'
  end

  def product_params
    keys = %i[body]
    keys << :checker_id if mentor_login?
    params.require(:product).permit(*keys)
  end

  def set_watch
    @watch = Watch.new
  end

  def set_wip
    @product.wip = params[:commit] == 'WIP'
  end

  def notice_message(product, action_name)
    return '提出物をWIPとして保存しました。' if product.wip?

    case action_name
    when :create
      '提出物を提出しました。'
    when :update
      '提出物を更新しました。'
    end
  end

  def notice_another_mentor_assigned_as_checker
    @checker_id = @product.checker_id
    return unless @checker_id && admin_or_mentor_login? && (@checker_id != current_user.id) && !@product.wip?

    ActivityDelivery.with(product: @product, receiver: User.find(@checker_id)).notify(:assigned_as_checker)
  end
end
