# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      @announcements = Announcement.order(created_at: :desc)
      render aciton: :index
    else
      render action: :welcome
    end
  end

  def welcome
  end
end
