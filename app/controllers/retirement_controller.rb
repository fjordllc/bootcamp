# frozen_string_literal: true

class RetirementController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]
  before_action :set_holding_regular_events, only: %i[new create]

  def show; end

  def new; end

  def create
    retirement = Retirement.by_self(retire_reason_params, user: current_user)

    if retirement.execute
      logout
      redirect_to retirement_url
    else
      current_user.retired_on = nil
      render :new
    end
  end

  private

  def retire_reason_params
    params.require(:user).permit(:retire_reason, :satisfaction, :opinion, retire_reasons: [])
  end

  def set_holding_regular_events
    @holding_regular_events = RegularEvent.organizer_event(current_user).holding
  end
end
