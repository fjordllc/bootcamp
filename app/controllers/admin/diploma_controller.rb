# frozen_string_literal: true

class Admin::DiplomaController < AdminController
  layout "diploma"

  def show
    @user = User.find(params[:user_id])
  end
end
