# frozen_string_literal: true

class Companies::UsersController < ApplicationController
  before_action :require_login

  def index
    @company = Company.find(params[:company_id])
    @users = User.with_attached_avatar.where(company: @company).order(updated_at: :desc)
  end
end
