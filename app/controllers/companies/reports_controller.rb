# frozen_string_literal: true

class Companies::ReportsController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
  end
end
