# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :require_login
  before_action :check_permission!, only: %i[show]
  before_action :require_staff_login, only: :index
  before_action :set_watch, only: %i[show]

  def index; end

  def show
    @product = find_product
    @reports = @product.user.reports.limit(10).order(reported_on: :DESC)
    @practice = find_practice
    @footprints = find_footprints
    footprint!
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
    if @product.save
      notify_to_slack(@product) unless @product.wip?
      redirect_to @product, notice: notice_message(@product, :create)
    else
      render :new
    end
  end

  def update
    @product = find_my_product
    set_wip
    if @product.update(product_params)
      redirect_to @product, notice: notice_message(@product, :update)
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

  def notify_to_slack(product)
    name = product.user.login_name.to_s
    link = "<#{url_for(product)}|#{product.title}>"

    return unless product.user.trainee? && product.user.company.slack_channel?

    SlackNotification.notify "#{name} さんが#{product.title}を提出しました。 #{link}",
                             username: "#{product.user.login_name} (#{product.user.name})",
                             icon_url: product.user.avatar_url,
                             channel: product.user.company.slack_channel,
                             attachments: [{
                               fallback: 'product body.',
                               text: product.body
                             }]
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
    if admin_login?
      Product.find(params[:id])
    else
      current_user.products.find(params[:id])
    end
  end

  def find_footprints
    find_product.footprints.with_avatar.order(created_at: :desc)
  end

  def footprint!
    return unless find_product.user != current_user

    find_product.footprints.create_or_find_by(user: current_user)
  end

  def check_permission!
    return if policy(find_product).show? || find_practice&.open_product?

    redirect_to root_path, alert: 'プラクティスを完了するまで他の人の提出物は見れません。'
  end

  def product_params
    params.require(:product).permit(:body)
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
      '提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。<br>7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。'
    when :update
      '提出物を更新しました。'
    end
  end
end
