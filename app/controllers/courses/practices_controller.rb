# frozen_string_literal: true

class Courses::PracticesController < ApplicationController
  before_action :require_login

  def index
    @course = Course.find(params[:course_id])
  end
end
