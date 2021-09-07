# frozen_string_literal: true

class API::CompaniesController < API::BaseController
  def index
    @companies = Company.with_attached_logo
  end
end
