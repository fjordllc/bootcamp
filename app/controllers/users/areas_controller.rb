# frozen_string_literal: true

class Users::AreasController < ApplicationController
  def index
    @number_of_users = Area.number_of_users
  end
end
