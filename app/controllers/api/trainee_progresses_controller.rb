# frozen_string_literal: true

class API::TraineeProgressesController < API::BaseController
  def index
    @trainees = User.trainees
                    .preload(:company, :course, :avatar_attachment, :completed_practices, :active_practices)
                    .order(:company_id, :created_at)
    @trainees = @trainees.where(company_id: params[:company_id]) if params[:company_id].present?
  end
end
