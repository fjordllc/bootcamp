# frozen_string_literal: true

class RetirementController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show; end

  def new; end

  def create
    current_user.assign_attributes(retire_reason_params)
    current_user.retired_on = Date.current
    if current_user.save(context: :retirement)
      user = current_user
      current_user.cancel_participation_from_regular_events
      current_user.delete_and_assign_new_organizer
      Newspaper.publish(:retirement_create, { user: })
      UserRetirement.new(user).execute

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
