# frozen_string_literal: true

class Users::CompaniesController < ApplicationController
  TARGETS = %w[all trainee adviser graduate mentor].freeze
  before_action :require_login

  def index
    @target = TARGETS.include?(params[:target]) ? params[:target] : TARGETS.first
  end
end
