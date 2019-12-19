# frozen_string_literal: true

class Events::ParticipationsController < ApplicationController
  before_action :set_event

  def create
    if @event.participations.create(user: current_user)
      redirect_to event_path(@event), notice: "出席登録が完了しました。"
    end
  end

  def destroy
    @event.participations.find_by(user_id: current_user.id).destroy
    redirect_to event_path(@event), notice: "出席をキャンセルしました。"
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end
end
