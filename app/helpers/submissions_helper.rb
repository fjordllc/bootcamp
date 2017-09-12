module SubmissionsHelper
  # @task_requests = params[:passed].present? ? TaskRequest.passed : TaskRequest.non_passed
  def passed_url?
    params[:passed] == "true"
  end

  def not_passed_url?
    params[:passed] == "false"
  end

  def passed_url_nil?
    params[:passed].nil?
  end

  def all_or_passed_status
    case params[:passed]
    when "true" then
      Submission.passed
    when "false" then
      Submission.non_passed
    when nil then
      Submission.all
    end
  end
end
