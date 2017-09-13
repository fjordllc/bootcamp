class SubmissionsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_practice, only: %i(create)
  before_action :set_submission, only: %i(edit update destroy)

  def create
    @submission      = @practice.submissions.build(submission_params)
    @submission.user = current_user

    if @submission.save
      @practice.pending(current_user)
      notify_to_slack(@submission, t("submission_new_slack_message"))
      redirect_to @submission.practice, notice: t("submission_notice")
    else
      render template: "practices/show"
    end
  end

  def edit
  end

  def update
    if @submission.update_attributes(submission_params)
      notify_to_slack(@submission, t("submission_edit"))
      redirect_back_or_to @submission.practice, notice: t("submission_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    @submission.destroy
    redirect_to @submission.practice, notice: t("submission_was_successfully_deleted")
  end

  private

    def submission_params
      params.require(:submission).permit(:content, :task)
    end

    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def notify_to_slack(submission, subject)
      name = "#{submission.user.login_name}"
      link = "<#{admin_submissions_confirm_url(submission)}#submission_#{submission.id}|#{submission.practice.title}>"

      notify "#{name} さんから#{subject}が届いています。 #{link}",
             username:    "#{submission.user.login_name} (#{submission.user.full_name})",
             icon_url:    gravatar_url(submission.user),
             attachments: [{
                               fallback: "submission body.",
                               text:     submission.content
                           }]
    end
end
