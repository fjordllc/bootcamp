# frozen_string_literal: true

class Admin::Metric::CheckController < AdminController
  def show
    @users = User.mentor.order(:created_at)
  end
end
