# frozen_string_literal: true

class Admin::CompaniesController < AdminController
  before_action :set_company, only: %i[edit update]
  skip_before_action :require_admin_login, only: %i[edit update]
  before_action :require_admin_or_adviser_login, only: %i[edit update]

  def index; end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to admin_companies_url, notice: '企業を作成しました。'
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: '企業を更新しました。'
    else
      render 'edit'
    end
  end

  def destroy
    @company = Company.find(params[:id])

    if @company.destroy
      redirect_to admin_companies_url, notice: '企業を削除しました。'
    else
      head :bad_request
    end
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
      :blog_url,
      :memo
    )
  end
  def require_admin_or_adviser_login
    return if admin_login? || (adviser_login? && current_user.company == @company)

    redirect_to root_path, alert: 'アクセス権限がありません'
  end
end
