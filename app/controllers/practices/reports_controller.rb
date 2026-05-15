# frozen_string_literal: true

class Practices::ReportsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @reports = @practice.reports.list.page(params[:page])
  end
end
