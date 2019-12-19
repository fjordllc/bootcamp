# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :require_login
  before_action :require_admin_login, except: %i(index show)
  before_action :set_event, only: %i(show edit update destroy)
  before_action :set_footprints, only: %i(show)
  def index
    @events = Event.with_avatar
                   .preload(:comments)
                   .order(created_at: :desc)
                   .page(params[:page])
  end

  def show
    footprint!
  end

  def new
    @event = Event.new(open_start_at: Time.current.beginning_of_minute)
  end

  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if @event.save
      redirect_to @event, notice: "イベントを作成しました。"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "イベントを更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "イベントを削除しました。"
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
        :open_end_at
      )
    end

    def set_event
      @event = Event.find(params[:id])
    end

    def set_footprints
      @footprints = @event.footprints.with_avatar.order(created_at: :desc)
    end

    def footprint!
      @event.footprints.where(user: current_user).first_or_create if @event.user != current_user
    end
end
