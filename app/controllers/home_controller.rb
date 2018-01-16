class HomeController < ApplicationController
  def index
    if current_user
      render action: :index
    else
      render action: :welcome
    end
  end

  def welcome
  end
end
