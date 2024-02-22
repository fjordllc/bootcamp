# frozen_string_literal: true

class Admin::CampaignsController < AdminController
  before_action :set_campaign, only: %i[edit update]

  def new
    start_at = Time.current.beginning_of_day
    @campaign = Campaign.new(
      start_at:,
      end_at: start_at + 7.days - 1.minute,
      trial_period: 7
    )
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      redirect_to admin_campaigns_path, notice: 'お試し延長を作成しました。'
    else
      render :new
    end
  end

  def index
    @campaigns = Campaign.order(end_at: :desc)
    @normal_students = User.where(admin: false, mentor: false, adviser: false, trainee: false)
    @continued_students = User.where(admin: false, mentor: false, adviser: false, trainee: false, retired_on: nil)
  end

  def edit; end

  def update
    if @campaign.update(campaign_params)
      redirect_to admin_campaigns_path, notice: 'お試し延長を更新しました。'
    else
      render :edit
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:start_at, :end_at, :title, :trial_period)
  end
end
