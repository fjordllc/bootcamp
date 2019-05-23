# frozen_string_literal: true

class Users::WorksController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @works = @user.works.eager_load(:user).order(updated_at: :desc)
  end
end
