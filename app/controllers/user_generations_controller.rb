# frozen_string_literal: true

class UserGenerationsController < ApplicationController
  before_action :require_login

  def show
    @generation = params[:id]
    start_date = generation_start_date(@generation)
    next_date = next_generation_date(start_date)
    @users = User.with_attached_avatar.same_generations(start_date, next_date)
  end

  private
    def generation_start_date(generation)
      g = generation.to_i
      y = (g - 1) / 4
      m = g - y * 4
      year = y + 2013
      month = m * 3 - 2
      Date.new(year, month, 1)
    end

    def next_generation_date(date)
      date.next_month(3)
    end
end
