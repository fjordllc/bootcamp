# frozen_string_literal: true

class Users::CompaniesController < ApplicationController
  TARGETS = %w[all trainee adviser graduate mentor].freeze

  def index
    @target = TARGETS.include?(params[:target]) ? params[:target] : TARGETS.first
  end
end
