# frozen_string_literal: true

class API::CodingTests::PositionController < API::BaseController
  before_action :require_admin_or_mentor_login_for_api, only: :update
  before_action -> { doorkeeper_authorize! :write }, only: :update, if: -> { doorkeeper_token.present? }

  def update
    @coding_test = CodingTest.find(params[:coding_test_id])
    if @coding_test.insert_at(params[:insert_at])
      head :no_content
    else
      render json: @coding_test.errors, status: :unprocessable_entity
    end
  end
end
