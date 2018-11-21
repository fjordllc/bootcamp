# frozen_string_literal: true

class Courses::Practices::PositionController < ApplicationController
  before_action :set_practice

  def update
    case params[:move]
    when "higher"
      @practice.move_higher
    when "lower"
      @practice.move_lower
    when "top"
      @practice.move_to_top
    when "bottom"
      @practice.move_to_bottom
    end

    redirect_back fallback_location: root_path
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end
end
