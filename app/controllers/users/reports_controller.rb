class Users::ReportsController < ApplicationController
  before_action :require_login
  before_action :set_user

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end
end
