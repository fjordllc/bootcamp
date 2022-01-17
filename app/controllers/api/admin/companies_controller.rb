# frozen_string_literal: true

class API::Admin::CompaniesController < API::Admin::BaseController
  before_action :require_login

  def index
    @companies = Company.with_attached_logo
                        .order(:id)
                        .page(params[:page])
  end

  def destroy
    @company = Company.find(params[:id])

    if @company.destroy
      head :no_content
    else
      head :bad_request
    end
  end
end
