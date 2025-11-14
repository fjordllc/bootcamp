# frozen_string_literal: true

class Api::Users::CompaniesController < Api::BaseController
  def index
    @companies = Company.with_attached_logo.order(:created_at).reverse_order
    @target = params[:target]
  end
end
