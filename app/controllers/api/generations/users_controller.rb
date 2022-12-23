# frozen_string_literal: true

class API::Generations::UsersController < API::BaseController
  def index
    generation = params[:generation_id].to_i
    target = params[:target]
    @users = Generation.new(generation).target_users(target)
  end
end
