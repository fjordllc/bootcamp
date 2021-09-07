# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :require_login

  def index; end

  def show
    @company = Company.find(params[:id])
  end
end
