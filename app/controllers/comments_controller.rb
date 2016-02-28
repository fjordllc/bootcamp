class CommentsController < ApplicationController
  before_action :set_user, only: :show

  def create
    @report = Report.find(params[:report_id])
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.report = @report

    if @comment.save
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
end
