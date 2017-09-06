class TaskRequestsController < ApplicationController
  before_action :set_practice, only: :create

  def create
    @task_request      = @practice.task_requests.build(task_request_params)
    @task_request.user = current_user

    if @task_request.save
      learning = Learning.find_or_create_by(
        user_id: current_user.id,
        practice_id: @practice.id
      )
      learning.update!(status: :task_checking)

      # slackの処理

      redirect_to @task_request.practice, notice: t("task_requested_notice")
    else
      redirect_to @task_request.practice, alert: @task_request.errors.full_messages
    end
  end

  private

    def task_request_params
      params.require(:task_request).permit(:content)
    end

    def set_practice
      @practice = Practice.find(params[:practice_id])
    end
end
