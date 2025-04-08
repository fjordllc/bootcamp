# frozen_string_literal: true

class Users::EventsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @events = @user.participate_events
                   .includes(:comments, :users)
                   .order(start_at: :desc)
                   .page(params[:page])
  end
end
