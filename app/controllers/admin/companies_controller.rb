class Admin::CompaniesController < AdminController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.all
  end

  def show
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to admin_companies_url, notice: t('company_was_successfully_created')
    else
      render 'new'
    end
  end

  def update
    if @company.update(company_params)
      redirect_to admin_companies_url, notice: t('company_was_successfully_updated')
    else
      render 'edit'
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_companies_url, notice: t('company_was_successfully_destroyed')
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(
        :name,
        :description,
        :website
      )
    end
end
