# frozen_string_literal: true

class Users::CompaniesController < ApplicationController
  ALLOWED_TARGETS = %w[all trainee adviser graduate mentor admin].freeze

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    @allowed_targets = ALLOWED_TARGETS
    @companies = Company.with_attached_logo.order(created_at: :desc)
    company_ids = @companies.map(&:id)
    filtered_users = User.with_attached_avatar.where(company_id: company_ids).users_role(@target, allowed_targets: @allowed_targets).order(:id)
    @company_users = filtered_users.group_by(&:company_id)
  end
end
