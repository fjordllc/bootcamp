# frozen_string_literal: true

class API::CodingTestSubmissionsController < API::BaseController
  def create
    cts = CodingTestSubmission.new(coding_test_submission_params)
    cts.user = current_user

    if cts.save
      head :ok
    else
      render json: { errors: cts.errors }, status: :unprocessable_entity
    end
  end

  private

  def coding_test_submission_params
    params.require(:coding_test_submission).permit(
      :coding_test_id,
      :code
    )
  end
end
