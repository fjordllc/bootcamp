class TaskRequestsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_practice, only: %i(create)
  before_action :set_task_request, only: %i(edit update destroy)

  def create
    @task_request      = @practice.task_requests.build(task_request_params)
    @task_request.user = current_user

    if @task_request.save
      @practice.with_task_checking(current_user)
      notify_to_slack(@task_request, t("task_request_new_slack_message"))
      redirect_to @task_request.practice, notice: t("task_requested_notice")
    else
      render template: "practices/show"
    end
  end

  def edit
  end

  def update
    if @task_request.update_attributes(task_request_params)
      notify_to_slack(@task_request, t("task_request_edit"))
      redirect_back_or_to @task_request.practice, notice: t("task_request_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    @task_request.destroy
    redirect_to @task_request.practice, notice: t("task_request_was_successfully_deleted")
  end

  private

    def task_request_params
      params.require(:task_request).permit(:content, :task)
    end

    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_task_request
      @task_request = TaskRequest.find(params[:id])
    end

    def notify_to_slack(task_request, subject)
      name = "#{task_request.user.login_name}"
      link = "<#{admin_task_request_url(task_request)}#task_request_#{task_request.id}|#{task_request.practice.title}>"

      notify "#{name} さんから#{subject}が届いています。 #{link}",
             username:    "#{task_request.user.login_name} (#{task_request.user.full_name})",
             icon_url:    gravatar_url(task_request.user),
             attachments: [{
                               fallback: "task_request body.",
                               text:     task_request.content
                           }]
    end
end
