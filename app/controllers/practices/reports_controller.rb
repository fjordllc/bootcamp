# frozen_string_literal: true

class Practices::ReportsController < ApplicationController
  before_action :require_login

  def index
    @practice = Practice.find(params[:practice_id])
    @reports = @practice.reports.eager_load(:user, :comments).order(updated_at: :desc, id: :desc).page(params[:page])
  end
end
