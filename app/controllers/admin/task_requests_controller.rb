class Admin::TaskRequestsController < AdminController
  before_action :set_task_request, only: %i(show passed)

  def index
    @task_requests =
        if params[:passed].present?
          TaskRequest.passed
        else
          TaskRequest.non_passed
        end
  end

  def show
  end

  def passed
    @task_request.update(passed: true)

    learning = Learning.find_or_create_by(
      user_id:     @task_request.user_id,
      practice_id: @task_request.practice_id
    )
    if params[:status].nil?
      learning.status = :complete
    else
      learning.status = params[:status].to_sym
    end

    # text = "<#{user_url(current_user)}|#{current_user.login_name}>が<#{practice_url(@practice)}|#{@practice.title}>を#{t learning.status}しました。"
    # notify text,
    #        username: "#{current_user.login_name}@256interns.com",
    #        icon_url: gravatar_url(current_user)

    if learning.save
      respond_to do |format|
        format.js { head :ok }
        format.html { redirect_back_or_to admin_task_requests_path, notice: t("notice_completed_practice") }
      end
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private

    def set_task_request
      @task_request = TaskRequest.find(params[:id])
    end
end
