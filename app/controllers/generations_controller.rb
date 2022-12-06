# frozen_string_literal: true

class GenerationsController < ApplicationController
  before_action :require_login
  TARGETS = %w[all trainee adviser graduate mentor retired].freeze

  def show
    @generation = params[:id].to_i
  end

  def index; end
end
