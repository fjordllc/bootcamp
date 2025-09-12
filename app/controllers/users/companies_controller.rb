# frozen_string_literal: true

class Users::CompaniesController < ApplicationController
  ALLOWED_TARGETS = %w[all trainee adviser graduate mentor admin].freeze

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    @companies = Company.with_attached_logo.order(:created_at).reverse_order
  end
end
