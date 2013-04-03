class HomeController < ApplicationController
  layout false
  def index
    if current_user.present?
      redirect_to controller: :users, action: :index
    end
  end
end
