class TaskRequestsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_practice, only: :create

  def create
    @task_request      = @practice.task_requests.build(task_request_params)
    @task_request.user = current_user

    if @task_request.save
      @practice.with_task_checking(current_user)
      notify_to_slack(@task_request)

      redirect_to @task_request.practice, notice: t("task_requested_notice")
    else
      redirect_to @task_request.practice, alert: @task_request.errors.full_messages
    end
  end

  private

    def task_request_params
      params.require(:task_request).permit(:content, :task)
    end

    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def notify_to_slack(task_request)
      name = "#{task_request.user.login_name}"
      link = "<#{admin_task_request_url(task_request)}#task_request_#{task_request.id}|#{task_request.practice.title}>"

      notify "#{name} さんから課題の確認依頼が届いています。 #{link}",
             username:    "#{task_request.user.login_name} (#{task_request.user.full_name})",
             icon_url:    gravatar_url(task_request.user),
             attachments: [{
                               fallback: "task_request body.",
                               text:     task_request.content
                           }]
    end
end
