# frozen_string_literal: true

class API::Practices::LearningController < API::BaseController
  include Rails.application.routes.url_helpers

  def show
    @learning = Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    return unless @learning.new_record?

    @learning.status = :unstarted
  end

  def update
    learning = Learning.find_or_initialize_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    learning.status = if params[:status].nil?
                        :complete
                      else
                        params[:status].to_sym
                      end

    status = learning.new_record? ? :created : :ok

    if learning.save
      head status
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end
end
