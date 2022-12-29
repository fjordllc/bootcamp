# frozen_string_literal: true

class Users::WorksController < ApplicationController
  before_action :require_login

  def index
    @user = User.find(params[:user_id])
    @works = @user.works.with_attached_thumbnail.eager_load(:user).order(updated_at: :desc)
  end
end
