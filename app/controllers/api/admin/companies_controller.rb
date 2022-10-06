# frozen_string_literal: true

class API::Admin::CompaniesController < API::Admin::BaseController
  def index
    per = params[:per] || 25
    @companies = Company.with_attached_logo
                        .order(:id)
                        .page(params[:page])
                        .per(per)
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
