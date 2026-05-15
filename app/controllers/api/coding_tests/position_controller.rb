# frozen_string_literal: true

class API::CodingTests::PositionController < API::BaseController
  def update
    @coding_test = CodingTest.find(params[:coding_test_id])
    if @coding_test.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @coding_test.errors, status: :unprocessable_entity
    end
  end
end
