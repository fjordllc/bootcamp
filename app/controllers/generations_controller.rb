# frozen_string_literal: true

class GenerationsController < ApplicationController
  before_action :require_login

  def show
    @generation = params[:id].to_i
    @users = Generation.new(@generation).users
  end

  def index
    @generations = Generation.generations.reverse
  end
end
