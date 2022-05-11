# frozen_string_literal: true

class Companies::ReportsController < ApplicationController
  before_action :require_login

  def index
    @company = Company.find(params[:company_id])
  end
end
