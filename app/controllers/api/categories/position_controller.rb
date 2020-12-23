# frozen_string_literal: true

class API::Categories::PositionController < API::BaseController
  def update
    @category = Category.find(params[:category_id])
    if @category.update(category_params)
      head :no_content
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.permit(:position)
  end
end
