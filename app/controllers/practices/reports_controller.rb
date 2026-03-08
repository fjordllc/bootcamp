# frozen_string_literal: true

class Practices::ReportsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @reports = Report.list.page(params[:page])
    @reports = @reports.with_practice_and_source(params[:practice_id]) if params[:practice_id].present?
    @reports = @reports.without_original_practice if params[:practice_id].present? && params[:grant_only] == 'true'
  end
end
