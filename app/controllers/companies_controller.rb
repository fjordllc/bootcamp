# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :require_login
  before_action :set_company

  def show
  end

  private
    def set_company
      @company = Company.find(params[:id])
    end
end
