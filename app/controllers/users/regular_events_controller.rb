# frozen_string_literal: true

class Users::RegularEventsController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @regular_events = @user.participate_regular_events
                           .includes(:comments, :users)
                           .order(start_at: :desc)
                           .page(params[:page])
  end
end
