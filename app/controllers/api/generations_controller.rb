# frozen_string_literal: true

class API::GenerationsController < API::BaseController
  before_action :require_login
  before_action :require_current_student
  PAGER_NUMBER = 24

  def show
    generation = params[:id].to_i
    @users = Generation.new(generation).users.page(params[:page]).per(PAGER_NUMBER)
  end

  def index
    result = Generation.generations(params[:target]).reverse
    @generations = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)
  end
end
