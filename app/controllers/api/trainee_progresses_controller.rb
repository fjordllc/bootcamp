# frozen_string_literal: true

class API::TraineeProgressesController < API::BaseController
  def index
    @trainees = User.trainees
                    .preload(:company, :course, :avatar_attachment, :active_practices)
                    .order(:company_id, :created_at)
    @trainees = @trainees.where(company_id: params[:company_id]) if params[:company_id].present?

    @week_start = if params[:week_start].present?
                    Date.parse(params[:week_start])
                  else
                    Date.current.beginning_of_week
                  end
    @week_end = @week_start + 4.days # 月〜金
  end
end
