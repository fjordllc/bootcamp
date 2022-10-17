# frozen_string_literal: true

class Admin::PracticesController < AdminController
  before_action :set_practice, only: %i[show edit update destroy]

  def index
    @practices = Practice.all
  end

  private

  def set_practice
    @practice = Practice.find(params[:id])
  end

  def practice_params
    params.require(:practice).permit(
      :title,
      :description,
      :goal,
      :submission,
      :open_product,
      :include_progress,
      :ogp_image,
      :memo,
      category_ids: [],
      practices_books_attributes: %i[id book_id must_read _destroy]
    )
  end

  def return_to
    course_id = params[:practice][:course_id]
    course_id.present? ? course_practices_url(course_id) : admin_practices_url
  end
end
