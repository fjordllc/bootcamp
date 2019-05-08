# frozen_string_literal: true

class Users::WorksController < ApplicationController
  before_action :set_user
  before_action :set_works

  def index
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def set_works
      @works = user.works.eager_load(:user).order(updated_at: :desc)
    end

    def user
      @user ||= User.find(params[:user_id])
    end
end
