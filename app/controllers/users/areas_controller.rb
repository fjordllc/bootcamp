# frozen_string_literal: true

class Users::AreasController < ApplicationController
  def index
    @number_of_users_by_region = Area.number_of_users_by_region
    @users_group_by_areas = Kaminari.paginate_array(Area.sorted_users_group_by_areas).page(params[:page]).per(15)
  end

  def show
    @area = params[:area_name]
    @users = Area.users_by_area(@area).page(params[:page]).per(15)
    @number_of_users_by_region = Area.number_of_users_by_region
  end
end
