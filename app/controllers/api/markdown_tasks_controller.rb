# frozen_string_literal: true

class API::MarkdownTasksController < API::BaseController
  before_action :set_taskable, only: :create

  def create
    checked = params[:checked].to_s.casecmp('true').zero?
    nth = params[:nth].to_i
    @taskable.toggle_task(nth, checked)

    if !@taskable.taskable?(current_user)
      head :bad_request
    elsif @taskable.save
      render json: { body: @taskable.body }, status: :ok
    else
      head :bad_request
    end
  end

  private

  def set_taskable
    taskable_type = params[:taskable_type]
    raise ActionController::BadRequest.new, 'Unsupported taskable type' unless %w[Announcement Answer Comment Page Report].include?(taskable_type)

    taskable_id = params[:taskable_id]
    @taskable = taskable_type.constantize.find(taskable_id)
  end
end
