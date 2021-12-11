# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  before_action :require_staff_login
  def index
    @target = params[:target]
    @target = 'unchecked_all' unless target_allowlist.include?(@target)
  end

  private

  def target_allowlist
    %w[unchecked_all unchecked_replied]
  end
end
