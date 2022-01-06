# frozen_string_literal: true

class API::Admin::CompaniesController < API::BaseController
  before_action :require_login

  def index
    @companies = Company.with_attached_logo
                        .order(:id)
                        .page(params[:page])

  end
end
