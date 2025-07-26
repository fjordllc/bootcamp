# frozen_string_literal: true

class Products::CheckerAssignmentsController < ApplicationController
  before_action :find_product
  before_action :require_staff_login

  def create
    return redirect_back(fallback_location: @product, alert: '既に担当者がいます。') if @product.checker.present?
    return redirect_back(fallback_location: @product, alert: '担当者になる権限がありません。') unless can_be_checker

    @product.update!(checker: current_user)
    redirect_back(fallback_location: @product, notice: '担当になりました。')
  end

  def destroy
    return redirect_back(fallback_location: @product, alert: '担当者が設定されていません。') if @product.checker.blank?
    return redirect_back(fallback_location: @product, alert: '担当者を削除する権限がありません。') unless can_remove_checker?

    @product.update!(checker: nil)
    redirect_back(fallback_location: @product, notice: '担当から外れました。')
  end

  private

  def find_product
    product_id = params[:product_id] || params[:id]
    @product = Product.find(product_id)
  end

  def can_be_checker?
    admin_or_mentor_login?
  end

  def can_remove_checker?
    @product.checker == current_user || admin_login?
  end
end
