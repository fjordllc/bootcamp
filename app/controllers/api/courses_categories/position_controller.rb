# frozen_string_literal: true

class API::CoursesCategories::PositionController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api, only: :update
  before_action -> { doorkeeper_authorize! :write }, only: :update, if: -> { doorkeeper_token.present? }

  def update
    @courses_category = CoursesCategory.find(params[:courses_category_id])
    if @courses_category.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @courses_category.errors, status: :unprocessable_entity
    end
  end
end
