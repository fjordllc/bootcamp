# frozen_string_literal: true

class Admin::PracticesController < AdminController
  before_action :set_practice, only: %i[show]

  def index
    @practices = Practice.all
  end

  def show; end

  private

  def set_practice
    @practice = Practice.find(params[:id])
  end

  def practice_params
    params.require(:practice).permit(
      :name,
      :slug,
      :description
    )
  end

  def return_to
    course_id = params[:practice][:course_id]
    course_id.present? ? course_practices_url(course_id) : admin_practices_url
  end
end
