# frozen_string_literal: true

class RetirementController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show; end

  def new
    @regular_events_without_finished = RegularEvent.organizer_event(current_user).exclude_finished
  end

  def create
    retirement = Retirement.by_self(retire_reason_params, user: current_user)

    if retirement.execute
      logout
      redirect_to retirement_url
    else
      current_user.retired_on = nil
      @regular_events_without_finished = RegularEvent.organizer_event(current_user).exclude_finished
      render :new
    end
  end

  private

  def retire_reason_params
    params.require(:user).permit(:retire_reason, :satisfaction, :opinion, retire_reasons: [])
  end
end
