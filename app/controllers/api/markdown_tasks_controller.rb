# frozen_string_literal: true

class API::MarkdownTasksController < API::BaseController
  def create
    taskable_type = params[:taskable_type]
    raise ActionController::BadRequest.new, 'Unsupported taskable type' unless %w[Announcement Answer Comment Page Report].include?(taskable_type)

    checked = params[:checked].to_s.casecmp('true').zero?
    nth = params[:nth].to_i
    taskable_id = params[:taskable_id]
    taskable = taskable_type.camelcase.constantize.find(taskable_id)

    taskable.toggle_task(nth, checked)

    if taskable.save
      render json: { body: taskable.body }, status: :ok
    else
      head :bad_request
    end
  end
end
