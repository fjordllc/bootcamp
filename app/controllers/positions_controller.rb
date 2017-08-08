class PositionsController < ApplicationController
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

    redirect_to practices_url
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end
end
