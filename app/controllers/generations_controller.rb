# frozen_string_literal: true

class GenerationsController < ApplicationController
  before_action :require_login

  def show
    @generation = params[:id].to_i
    @users = Generation.new(@generation).users
  end

  def index
    @generations = (1..max_generation_number).map { |n| Generation.new(n) }
  end

  private

    def max_generation_number
      now_time = Time.now
      (now_time.year - 2013) * 4 + (now_time.month + 2) / 3
    end
end
