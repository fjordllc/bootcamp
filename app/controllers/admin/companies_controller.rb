# frozen_string_literal: true

class Admin::CompaniesController < AdminController
  before_action :set_company, only: [:edit, :update, :destroy]

  def index
    @companies = Company.with_attached_logo.order(:id)
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      @company.resize_logo!
      redirect_to admin_companies_url, notice: "会社を作成しました。"
    else
      render "new"
    end
  end

  def update
    if @company.update(company_params)
      @company.resize_logo!
      redirect_to admin_companies_url, notice: "会社を更新しました。"
    else
      render "edit"
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_companies_url, notice: "会社を削除しました。"
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(
      :name,
      :description,
      :website,
      :slack_channel,
      :logo
    )
  end
end
