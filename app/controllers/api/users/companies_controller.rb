# frozen_string_literal: true

class API::Users::CompaniesController < API::BaseController
  before_action :require_login_for_api

  def index
    @companies = Company.with_attached_logo.order(:id)
  end

  def show
    @company = Company.find(params[:id])
  end
end
