# frozen_string_literal: true

class Users::AreasController < ApplicationController
  def index
    @number_of_users_by_region = Area.number_of_users_by_region
  end
end
