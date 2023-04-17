# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    @companies = Company.with_attached_logo
  end

  def show
    @company = Company.find(params[:id])
  end
end
