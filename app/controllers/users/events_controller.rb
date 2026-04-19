# frozen_string_literal: true

class Users::EventsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @events = Event.where(id: @user.participate_events.select(:id))
                   .or(Event.where(user_id: current_user.id))
                   .includes(:comments, :users)
                   .order(start_at: :desc)
                   .page(params[:page])
  end
end
