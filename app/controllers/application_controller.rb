class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :init_user

  protected
    def not_authenticated
      redirect_to login_path, :alert => "Please login first."
    end

  private
    def init_user
      if current_user
        @current_user = User.find(current_user.id)
      end
    end
end
