# frozen_string_literal: true

class CoursesController < ApplicationController
  skip_before_action :require_active_user_login, raise: false

  def index
    if logged_in?
      @courses = Course.order(created_at: :desc)
    else
      @rails_course = Course.preload(categories: :practices).find_by(title: 'Railsエンジニア')
      @frontend_course = Course.preload(categories: :practices).find_by(title: 'フロントエンドエンジニア')
      render 'welcome/courses', layout: 'lp'
    end
  end

  private

  def course_params
    params.require(:course).permit(
      :title,
      :description,
      :published,
      :grant,
      category_ids: []
    )
  end
end
