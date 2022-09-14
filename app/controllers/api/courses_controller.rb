# frozen_string_literal: true

class API::CoursesController < API::BaseController
  def index
    @courses = Course.order(:id)
  end
end
