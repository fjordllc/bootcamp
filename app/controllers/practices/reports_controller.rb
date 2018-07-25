class Practices::ReportsController < ApplicationController
  def show
    @practice = Practice.find(params["practice_id"])
    @reports = @practice.reports.eager_load(:user, :comments).order(updated_at: :desc)
  end
end
