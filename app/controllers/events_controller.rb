# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :require_login
  before_action :set_event, only: %i[show edit update destroy]
  before_action :set_footprints, only: %i[show]

  def index; end

  def show
    footprint!
  end

  def new
    @event = Event.new(open_start_at: Time.current.beginning_of_minute)

    return unless params[:id]

    event              = Event.find(params[:id])
    @event.title       = event.title
    @event.location    = event.location
    @event.capacity    = event.capacity
    @event.open_start_at = Time.current.beginning_of_minute
    @event.description = event.description
    flash.now[:notice] = 'イベントをコピーしました。'
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    set_wip
    if @event.save
      redirect_to @event, notice: notice_message(@event)
    else
      render :new
    end
  end

  def edit; end

  def update
    set_wip
    if @event.update(event_params)
      @event.update_participations if @event.saved_change_to_attribute?('capacity')
      redirect_to @event, notice: notice_message(@event)
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'イベントを削除しました。'
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
      :job_hunting
    )
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def set_footprints
    @footprints = @event.footprints.with_avatar.order(created_at: :desc)
  end

  def footprint!
    @event.footprints.create_or_find_by(user: current_user) if @event.user != current_user
  end

  def set_wip
    @event.wip = (params[:commit] == 'WIP')
  end

  def notice_message(event)
    case params[:action]
    when 'create'
      event.wip? ? 'イベントをWIPとして保存しました。' : 'イベントを作成しました。'
    when 'update'
      event.wip? ? 'イベントをWIPとして保存しました。' : 'イベントを更新しました。'
    end
  end
end
