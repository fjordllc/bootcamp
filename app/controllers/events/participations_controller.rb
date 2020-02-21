# frozen_string_literal: true

class Events::ParticipationsController < ApplicationController
  before_action :set_event

  def create
    if @event.participants_full?
      @event.participations.create(user: current_user, enable: false)
    else
      @event.participations.create(user: current_user, enable: true)
    end
    redirect_to event_path(@event), notice: "出席登録が完了しました。"
  end

  def destroy
    @event.participations.find_by(user_id: current_user.id).destroy
    redirect_to event_path(@event), notice: "参加を取り消しました。"
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end
end
