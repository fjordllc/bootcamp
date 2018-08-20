class Practices::ReportsController < ApplicationController
  before_action :set_practice
  before_action :set_reports

  def index
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_reports
      @reports = @practice.reports.eager_load(:user, :comments).order(updated_at: :desc, id: :desc)
    end
end
