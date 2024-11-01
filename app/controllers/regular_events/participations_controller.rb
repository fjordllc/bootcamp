# frozen_string_literal: true

class RegularEvents::ParticipationsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  before_action :set_regular_event

  def create
    @regular_event.regular_event_participations.create(user: current_user)
    create_watch
    redirect_to regular_event_path(@regular_event), notice: '参加登録しました。'
  end

  def destroy
    if params[:participant_id] && current_user.admin?
      user = User.find(params[:participant_id])
      @regular_event.cancel_participation(user)
    else
      @regular_event.cancel_participation(current_user)
    end
    redirect_to regular_event_path(@regular_event), notice: '参加を取り消しました。'
  end

  private

  def set_regular_event
    @regular_event = RegularEvent.find(params[:regular_event_id])
  end

  def create_watch
    return if @regular_event.watched_by?(current_user)

    watch = Watch.new(
      user: current_user,
      watchable: @regular_event
    )
    watch.save!
  end
end
