class CurrentUserController < ApplicationController
  before_action :require_login

  def update
    current_user.accessed_at = Time.now
    if current_user.save!
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
