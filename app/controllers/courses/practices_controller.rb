# frozen_string_literal: true

class Courses::PracticesController < ApplicationController
  include Gravatarify::Helper
  before_action :require_login
  before_action :set_course

  def index
    # TODO: リタイアした人のセッションが切れたら外す
    if current_user.retired_on?
      logout
      redirect_to retire_path
    end
  end

  private
    def set_course
      @course = Course.find(params[:course_id])
    end
end
