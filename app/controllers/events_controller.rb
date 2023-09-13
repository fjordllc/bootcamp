# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: %i[edit update destroy]

  def index; end

  def show
    @event = Event.with_avatar.find(params[:id])
  end

  def new
    @event = Event.new(open_start_at: Time.current.beginning_of_minute)

    return unless params[:id]

    copy_event(@event)
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    set_wip
    if @event.save
      update_published_at
      Newspaper.publish(:event_create, @event)
      url = publish_with_announcement? ? new_announcement_path(event_id: @event.id) : Redirection.determin_url(self, @event)
      redirect_to url, notice: notice_message(@event)
    else
      render :new
    end
  end

  def edit; end

  def update
    set_wip
    if @event.update(event_params)
      update_published_at
      @event.update_participations if !@event.wip? && @event.can_move_up_the_waitlist?
      url = publish_with_announcement? ? new_announcement_path(event_id: @event.id) : Redirection.determin_url(self, @event)
      redirect_to url, notice: notice_message(@event)
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: '特別イベントを削除しました。'
  end

  private

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      :location,
      :capacity,
      :start_at,
      :end_at,
      :open_start_at,
      :open_end_at,
      :job_hunting,
      :announcement_of_publication
    )
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def set_wip
    @event.wip = (params[:commit] == 'WIP')
  end

  def redirect_url(event)
    return new_announcement_path(event_id: event.id) if publish_with_announcement?

    event.wip? ? edit_event_url(event) : event_url(event)
  end

  def notice_message(event)
    case params[:action]
    when 'create'
      event.wip? ? '特別イベントをWIPとして保存しました。' : '特別イベントを作成しました。'
    when 'update'
      event.wip? ? '特別イベントをWIPとして保存しました。' : '特別イベントを更新しました。'
    end
  end

  def copy_event(new_event)
    event = Event.find(params[:id])
    new_event.title       = event.title
    new_event.location    = event.location
    new_event.capacity    = event.capacity
    new_event.open_start_at = Time.current.beginning_of_minute
    new_event.description = event.description
    new_event.job_hunting = event.job_hunting

    flash.now[:notice] = '特別イベントをコピーしました。'
  end

  def update_published_at
    return if @event.wip || @event.published_at?

    @event.update(published_at: Time.current)
  end

  def publish_with_announcement?
    !@event.wip? && @event.announcement_of_publication?
  end
end
