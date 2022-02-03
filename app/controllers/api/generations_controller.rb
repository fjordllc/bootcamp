# frozen_string_literal: true

class API::GenerationsController < API::BaseController
  before_action :require_login
  PAGER_NUMBER = 20

  def show
    generation = params[:id].to_i
    @users = Generation.new(generation).users.page(params[:page]).per(PAGER_NUMBER)
  end
end
