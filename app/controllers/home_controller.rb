class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to controller: :users, action: :index
    end

    render :action 'index', layout: false
  end

  def application
  end
end
