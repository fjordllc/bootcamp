# frozen_string_literal: true

class ChecksController < ApplicationController
  before_action :require_staff_login

  def create
    @checkable = find_checkable

    if @checkable.checks.exists?(user: current_user)
      checkable_name = @checkable.is_a?(Product) ? '提出物' : '日報'
      redirect_back(fallback_location: @checkable, alert: "この#{checkable_name}は確認済です。")
      return
    end

    @check = @checkable.checks.build(user: current_user)

    if @check.save
      if @checkable.is_a?(Product)
        redirect_back(fallback_location: @checkable, notice: '提出物を合格にしました。')
      else
        redirect_back(fallback_location: @checkable, notice: '日報を確認済みにしました。')
      end
    else
      redirect_back(fallback_location: @checkable, alert: 'エラーが発生しました。')
    end
  end

  def destroy
    @check = Check.find(params[:id])
    @checkable = @check.checkable

    @check.destroy
    redirect_back(fallback_location: @checkable)
  end

  private

  def find_checkable
    if params[:product_id]
      Product.find(params[:product_id])
    elsif params[:report_id]
      Report.find(params[:report_id])
    else
      raise ActionController::ParameterMissing, 'product_id or report_id is required'
    end
  end
end
