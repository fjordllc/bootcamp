# frozen_string_literal: true

class Users::CompaniesController < ApplicationController
  ALLOWED_TARGETS = %w[all trainee adviser graduate mentor].freeze

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
  end
end
