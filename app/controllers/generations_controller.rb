# frozen_string_literal: true

class GenerationsController < ApplicationController
  before_action :require_login
  TARGETS = %w[all trainee adviser graduate mentor retired].freeze

  def show
    @generation = params[:id].to_i
    @users = Generation.new(@generation).users
  end

  def index
    @target = TARGETS.include?(params[:target]) ? params[:target] : TARGETS.first
    redirect_to root_path, alert: '管理者としてログインしてください' if @target == 'retired' && !current_user.admin?
    @generations = Generation.generations.reverse
  end
end
