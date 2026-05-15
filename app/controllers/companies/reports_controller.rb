# frozen_string_literal: true

class Companies::ReportsController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    @reports = Report.list
                     .joins(:user)
                     .where(users: { company_id: @company.id })
                     .page(params[:page])
  end
end
