# frozen_string_literal: true

class Scheduler::StatisticsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update
    unless ENV["TOKEN"] == params[:token]
      return head :unauthorized
    end

    Practice.save_learning_minute_statistics
    head :ok
  end
end
