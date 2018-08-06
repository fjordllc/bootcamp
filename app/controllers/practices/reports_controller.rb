class Practices::ReportsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @reports = @practice.reports.eager_load(:user, :comments).order(updated_at: :desc)
  end
end
