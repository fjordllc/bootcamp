# frozen_string_literal: true

class API::MarkdownTasksController < API::BaseController
  def create
    checked = params[:checked].to_s.casecmp('true').zero?
    nth = params[:nth].to_i
    taskable_id = params[:taskable_id]
    taskable_type = params[:taskable_type]
    taskable = taskable_type.camelcase.constantize.find(taskable_id)

    taskable.toggle_task(nth, checked)

    if taskable.save
      render json: { body: taskable.body }, status: :ok
    else
      head :bad_request
    end
  end
end
