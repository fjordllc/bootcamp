# frozen_string_literal: true

class Products::SelfAssignedController < ApplicationController
  before_action :require_staff_login
  def index
    @target = params[:target]
    @target = 'self_assigned_all' unless target_allowlist.include?(@target)
  end

  private

  def target_allowlist
    %w[self_assigned_no_replied self_assigned_all]
  end
end
