class Admin::TaskRequestsController < AdminController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_task_request, only: %i(show passed)

  def index
    @task_requests = params[:passed].present? ? TaskRequest.passed : TaskRequest.non_passed
  end

  def show
  end

  def passed
    if @task_request.practice.with_complete(@task_request.user)
      @task_request.update(passed: true)
      notify_to_slack(@task_request)

      redirect_to admin_task_requests_path, notice: t("notice_completed_practice")
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private

    def set_task_request
      @task_request = TaskRequest.find(params[:id])
    end

    def notify_to_slack(task_request)
      name       = "#{task_request.user.login_name}"
      link       = "<#{practice_url(task_request.practice)}#practice_#{task_request.practice.id}|#{task_request.practice.title}>"

      notify "#{name} さん #{task_request.practice.title}の課題確認しました。 #{link}",
             username:    "#{current_user.login_name} (#{current_user.full_name})",
             icon_url:    gravatar_url(current_user),
             attachments: [{
                               fallback: "passed body.",
                               text:     "#{task_request.practice.title}のプラクティス完了です！"
                           }]
    end
end
