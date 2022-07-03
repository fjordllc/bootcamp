# frozen_string_literal: true

class API::Users::CompaniesController < API::BaseController
  def index
    @companies = Company.with_attached_logo.order(:id)
    @target = params[:target]
  end
end
