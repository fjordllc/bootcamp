# frozen_string_literal: true

class HibernationController < ApplicationController
  skip_before_action :require_active_user_login, raise: false, only: %i[show]

  def show; end

  def new
    @hibernation = Hibernation.new
    @regular_events_without_finished = RegularEvent.organizer_event(current_user).exclude_finished
  end

  def create
    @hibernation = Hibernation.new(hibernation_params)
    @hibernation.user = current_user

    if @hibernation.save
      @hibernation.execute

      logout
      redirect_to hibernation_path
    else
      @regular_events_without_finished = RegularEvent.organizer_event(current_user).exclude_finished
      render :new
    end
  end

  private

  def hibernation_params
    params.require(:hibernation).permit(:reason, :scheduled_return_on, :returned_on)
  end
end
