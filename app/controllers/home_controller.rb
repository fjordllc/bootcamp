# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      if current_user.retire?
        logout
        redirect_to retire_path
      else
        @announcements = Announcement.limit(5).order(created_at: :desc)
        render aciton: :index
      end
    else
      render action: :welcome
    end
  end

  def welcome
  end
end
