# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      if current_user.retired_on?
        logout
        redirect_to retire_path
      else
        @announcements = Announcement.with_avatar
                                     .limit(5)
                                     .order(created_at: :desc)
        @completed_learnings = current_user.learnings.where(status: 3).order(updated_at: :desc)
        @my_seat_today = current_user.reservations.find_by(date: Date.current)&.seat&.name
        @reservation_today = Reservation.where(date: Date.current)
        render aciton: :index
      end
    else
      render template: "welcome/index", layout: "welcome"
    end
  end

  def pricing
  end
end
