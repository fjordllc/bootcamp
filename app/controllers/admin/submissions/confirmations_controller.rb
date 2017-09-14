class Admin::Submissions::ConfirmationsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_submission, only: %i(show update)

  def index
    @submissions = Submission.where(passed: false)
  end

  def show
  end

  def update
    if @submission.practice.complete(@submission.user)
      @submission.to_pass
      notify_to_slack(@submission)

      redirect_to admin_submissions_confirmations_path, notice: t("submission_pass_message")
    else
      render json: learning.errors, status: :unprocessable_entity
    end
  end

  private

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def notify_to_slack(submission)
      name = "#{submission.user.login_name}"
      link = "<#{practice_url(submission.practice)}#practice_#{submission.practice.id}|#{submission.practice.title}>"

      notify "#{name} さん #{submission.practice.title}の課題確認しました。 #{link}",
             username:    "#{current_user.login_name} (#{current_user.full_name})",
             icon_url:    gravatar_url(current_user),
             attachments: [{
                               fallback: "passed body.",
                               text:     "#{submission.practice.title}のプラクティス完了です！"
                           }]
    end
end
