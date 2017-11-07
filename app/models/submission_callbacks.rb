class SubmissionCallbacks
  def after_create(submission)
    unless submission.sender.admin?
      Notification.came_submission(submission)
    end
  end
end
