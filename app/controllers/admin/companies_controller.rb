# frozen_string_literal: true

class Admin::CompaniesController < AdminController
  before_action :set_company, only: %i[edit update destroy]

  def index
    @companies = Company.with_attached_logo.order(:id).page(params[:page])
  end

  def new
    @company = Company.new
  end

  def edit; end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to admin_companies_url, notice: '企業を作成しました。'
    else
      render 'new'
    end
  end

  def update
    if @company.update(company_params)
      redirect_to admin_companies_url, notice: '企業を更新しました。'
    else
      render 'edit'
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_companies_url, notice: '企業を削除しました。'
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
      :logo,
      :blog_url
    )
  end
end
