# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      redirect_to announcements_path
    else
      render action: :welcome
    end
  end

  def welcome
  end
end
