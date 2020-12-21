# frozen_string_literal: true

class API::Categories::PositionController < API::BaseController
  def update
    @category = Category.find(params[:category_id])
    if @category.update(position: params[:position])
      render :update, status: :ok
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.require(:category).permit(:position)
  end
end
