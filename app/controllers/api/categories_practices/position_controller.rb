# frozen_string_literal: true

class API::CategoriesPractices::PositionController < API::BaseController
  wrap_parameters :categories_practice

  def update
    @categories_practice = CategoriesPractice.find(params[:id])
    if @categories_practice.update(categories_practice_params)
      head :no_content
    else
      render json: @categories_practice.errors, status: :unprocessable_entity
    end
  end

  private

  def categories_practice_params
    params.require(:categories_practice).permit(:position)
  end
end
