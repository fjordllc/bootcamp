# frozen_string_literal: true

class Api::CategoriesPractices::PositionController < Api::BaseController
  def update
    @categories_practice = CategoriesPractice.find(params[:categories_practice_id])
    if @categories_practice.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @categories_practice.errors, status: :unprocessable_entity
    end
  end
end
