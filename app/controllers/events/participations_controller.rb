# frozen_string_literal: true

class Events::ParticipationsController < ApplicationController
  before_action :set_event
  skip_before_action :require_active_user_login, raise: false

  def create
    return if current_user.trainee && @event.job_hunting

    return unless @event.participations.create(user: current_user, enable: @event.can_participate?)

    create_watch
    redirect_to event_path(@event), notice: '参加登録しました。'
  end

  def destroy
    @event.with_lock do
      @event.cancel_participation!(current_user)
    end
    redirect_to event_path(@event), notice: '参加を取り消しました。'
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def create_watch
    return if @event.watched_by?(current_user)

    watch = Watch.new(
      user: current_user,
      watchable: @event
    )
    watch.save!
  end
end
