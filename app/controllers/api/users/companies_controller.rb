# frozen_string_literal: true

class API::Users::CompaniesController < API::BaseController
  def index
    @companies = Company.with_attached_logo.order(:updated_at).reverse_order
    @target = params[:target]
  end
end
