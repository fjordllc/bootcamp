# frozen_string_literal: true

class API::ReportsController < ApplicationController
  def show
    @report = Report.find(params[:id])
    render "show", formats: "json", handlers: "jbuilder"
  end
end
