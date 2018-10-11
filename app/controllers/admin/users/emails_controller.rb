# frozen_string_literal: true

class Admin::Users::EmailsController < AdminController
  def index
    @users = User.where(adviser: false, retire: false)
  end
end
