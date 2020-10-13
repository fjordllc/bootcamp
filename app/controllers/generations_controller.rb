# frozen_string_literal: true

class GenerationsController < ApplicationController
  before_action :require_login

  def show
    @generation = params[:id].to_i
    start_date = Generation.start_date(@generation)
    next_date = Generation.start_date(@generation + 1)
    @users = User.with_attached_avatar.same_generations(start_date, next_date)
  end
end
