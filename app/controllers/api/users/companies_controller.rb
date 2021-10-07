# frozen_string_literal: true

class API::Users::CompaniesController < API::BaseController
  def index
    @companies = Company.with_attached_logo.order(:id)
  end
end
