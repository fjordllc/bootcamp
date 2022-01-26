# frozen_string_literal: true

class Admin::CampaignsController < AdminController
  before_action :set_campaign, only: %i[edit update]
  def new
    @campaign = Campaign.new(start_at: Time.current.beginning_of_day)
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
    params.require(:campaign).permit(:start_at, :end_at, :title)
  end
end
