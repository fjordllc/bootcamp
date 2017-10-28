class Admin::Submissions::ReviewsController < ApplicationController
  before_action :set_submission, only: %i(create edit update destroy)
  before_action :set_practice, only: %i(create edit update destroy)

  def create
    @review      = @submission.reviews.build(review_params)
    @review.user = current_user
    if @review.save
      redirect_to @submission, notice: t("review_was_successfully_created")
    else
      render "practices/show"
    end
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    @review = Review.find(params[:id])
    if @review.update_attributes(review_params)
      redirect_to admin_submissions_confirmation_review_path(@submission, @review), notice: t("review_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to @practice, notice: t("review_was_successfully_deleted")
  end

  private

    def review_params
      params.require(:review).permit(:message)
    end

    def set_practice
      @practice = @submission.practice
    end

    def set_submission
      @submission = Submission.find(params[:submissions_id])
    end
end
