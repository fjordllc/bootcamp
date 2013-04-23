class HomeController < ApplicationController
  layout false, only: %w(index)
  def index
    if current_user.present?
      redirect_to controller: :users, action: :index
    end
  end

  def application
  end
end
