# frozen_string_literal: true

class Companies::UsersController < ApplicationController
  before_action :require_login
  before_action :set_company
  before_action :set_users

  def index
  end

  private
    def set_company
      @company = Company.find(params[:company_id])
    end

    def set_users
      @users = User.with_attached_avatar.where(company: company).order(updated_at: :desc)
    end

    def company
      @company ||= Company.find(params[:company_id])
    end
end
