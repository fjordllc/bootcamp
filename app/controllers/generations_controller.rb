# frozen_string_literal: true

class GenerationsController < ApplicationController
  ALLOWED_TARGETS = %w[all trainee adviser graduate mentor retired].freeze
  PAGER_NUMBER = 24

  def show
    @generation = params[:id].to_i
    @users = Generation.new(@generation).classmates.page(params[:page]).per(PAGER_NUMBER)
  end

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    redirect_to root_path, alert: '管理者としてログインしてください' if @target == 'retired' && !current_user.admin?

    result = Generation.generations(@target).reverse
    @generations = Kaminari.paginate_array(result).page(params[:page]).per(PAGER_NUMBER)
  end
end
