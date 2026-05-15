# frozen_string_literal: true

class Users::CompaniesController < ApplicationController
  ALLOWED_TARGETS = %w[all trainee adviser graduate mentor admin].freeze

  def index
    @target = ALLOWED_TARGETS.include?(params[:target]) ? params[:target] : ALLOWED_TARGETS.first
    @allowed_targets = ALLOWED_TARGETS
    @companies = Company.with_attached_logo.order(created_at: :desc)
    @company_users = User
                     .with_attached_avatar
                     .where(company_id: @companies.map(&:id))
                     .users_role(@target, allowed_targets: @allowed_targets)
                     .order(:id)
                     .group_by(&:company_id)
  end
end
