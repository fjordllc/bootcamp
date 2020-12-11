# frozen_string_literal: true

class SchedulerController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :require_token

  protected

  def require_token
    return if ENV['TOKEN'] == params[:token]

    head :unauthorized
  end
end
