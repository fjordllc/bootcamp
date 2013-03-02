class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init_user

  private
  def init_user
    if current_user
      @current_user = User.find(current_user.id)
    end
  end
end
