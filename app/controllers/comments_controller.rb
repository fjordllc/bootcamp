class CommentsController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_user, only: :show
  before_action :set_my_comment, only: %i(edit update destroy)

  def create
    @report = Report.find(params[:report_id])
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.report = @report

    if @comment.save
      notify_to_slack(@comment)
      redirect_to @report, notice: t('comment_was_successfully_created')
    else
      render :new
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    @report = Report.find_by(id: @comment.report_id)
  end

  def update
    @comment = Comment.find(params[:id])
    @report = Report.find_by(id: @comment.report_id)

    if @comment.update(comment_params)
      redirect_to @report, notice: t('comment_was_successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @report = Report.find_by(id: @comment.report_id)
    @comment.destroy
    redirect_to @report, notice: t('comment_was_successfully_deleted')
  end

  private

  def comment_params
    params.require(:comment).permit(
      :description
    )
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
  end

  def set_my_comment
    @comment = current_user.comments.find(params[:id])
  end

  def notify_to_slack(comment)
    name = "#{comment.user.login_name}"
    link = "<#{report_url(comment.report)}#comment_#{comment.id}|#{comment.report.title}>"

    notify "#{name} commented to #{link}",
      username: "#{comment.user.login_name} (#{comment.user.full_name})",
      icon_url: gravatar_url(comment.user),
      attachments: [{
        fallback: "comment body.",
        text: comment.description
      }]
  end
end
