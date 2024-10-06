# frozen_string_literal: true

class Users::AreasController < ApplicationController
  PAGER_NUMBER = 15

  def index
    @number_of_users_by_region = Area.number_of_users_by_region
    @sorted_user_groups_by_area_user_num = Kaminari.paginate_array(Area.sorted_user_groups_by_area_user_num).page(params[:page]).per(PAGER_NUMBER)
  end

  def show
    @area = params[:area]
    @users = User.by_area(@area).page(params[:page]).per(PAGER_NUMBER)
    @number_of_users_by_region = Area.number_of_users_by_region
  end
end
