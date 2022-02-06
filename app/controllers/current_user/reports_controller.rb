# frozen_string_literal: true

require 'tmpdir'

class CurrentUser::ReportsController < ApplicationController
  before_action :require_login
  before_action :set_user
  before_action :set_reports

  def index
  end

  private

  def set_user
    @user = current_user
  end

  def set_reports
    @reports = user.reports.list.page(params[:page])
  end

  def user
    @user ||= current_user
  end
end
