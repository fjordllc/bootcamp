# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      if current_user.retired_on?
        logout
        redirect_to retire_path
      else
        @announcements = Announcement.limit(5).order(created_at: :desc)
        render aciton: :index
      end
    else
      render template: "welcome/index", layout: "welcome"
    end
  end

  def pricing
  end
end
