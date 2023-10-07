# frozen_string_literal: true

class Users::AreasController < ApplicationController
  def index
    @user_counts = Area.user_counts_by_subdivision
  end
end
