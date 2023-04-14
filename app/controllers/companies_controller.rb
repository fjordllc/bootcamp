# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    @companies = Company.with_attached_logo
    @total_count_registered_company = Company.count
  end

  def show
    @company = Company.find(params[:id])
  end
end
