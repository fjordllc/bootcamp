# frozen_string_literal: true

class API::Generations::UsersController < API::BaseController
  def index
    generation = params[:generation_id].to_i
    @users = Generation.new(generation).users
  end
end
