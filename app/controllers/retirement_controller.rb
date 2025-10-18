# frozen_string_literal: true

class RetirementController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show; end

  def new; end

  def create
    retirement = Retirement.new(current_user, triggered_by: 'user')

    if retirement.call(retire_reason_params)
      current_user.cancel_participation_from_regular_events
      current_user.delete_and_assign_new_organizer

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
end
