# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :require_login
  
  def index
    @companies = Company.with_attached_logo
  end
  def show
    @company = Company.find(params[:id])
  end
end
