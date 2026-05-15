# frozen_string_literal: true

class ChecksController < ApplicationController
  before_action :require_staff_login

  def create
    @checkable = find_checkable

    if @checkable.checks.exists?
      checkable_name = @checkable.is_a?(Product) ? '提出物' : '日報'
      redirect_back(fallback_location: @checkable, alert: "この#{checkable_name}は確認済です。")
      return
    end

    @check = @checkable.checks.build(user: current_user)

    begin
      Check.transaction do
        @check.save!
        ActiveSupport::Notifications.instrument('check.create', check: @check)
      end
      notice = @checkable.is_a?(Product) ? '提出物を合格にしました。' : '日報を確認済みにしました。'
      redirect_back(fallback_location: @checkable, notice:)
    rescue StandardError => e
      Rails.logger.error("[ChecksController#create] チェック作成でエラー: #{e.message}")
      redirect_back(fallback_location: @checkable, alert: 'エラーが発生しました。')
    end
  end

  def destroy
    @check = Check.find(params[:id])
    @checkable = @check.checkable

    begin
      Check.transaction do
        @check.destroy!
        ActiveSupport::Notifications.instrument('check.cancel', check: @check)
      end
      redirect_back(fallback_location: @checkable)
    rescue StandardError => e
      Rails.logger.error("[ChecksController#destroy] チェック削除でエラー: #{e.message}")
      redirect_back(fallback_location: @checkable, alert: 'エラーが発生しました。')
    end
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
