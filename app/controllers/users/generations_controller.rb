# frozen_string_literal: true

class Users::GenerationsController < ApplicationController
  TARGETS = %w[all trainee adviser graduate mentor retired].freeze
  before_action :require_login

  def index
    @target = TARGETS.include?(params[:target]) ? params[:target] : TARGETS.first
  end
end
