# frozen_string_literal: true

class Users::RegionsController < ApplicationController
  def index
    @number_of_users_by_region = Region.number_of_users_by_region
  end
end
