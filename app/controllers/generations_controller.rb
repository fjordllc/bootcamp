# frozen_string_literal: true

class GenerationsController < ApplicationController
  ALLOWED_TARGETS = %w[all trainee adviser graduate mentor retired].freeze

  def show
    @generation = params[:id].to_i
  end

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    redirect_to root_path, alert: '管理者としてログインしてください' if @target == 'retired' && !current_user.admin?
  end
end
