class ReviewsController < ApplicationController
  before_action :set_submission, only: %i(create)
  before_action :set_review, only: %i(edit update destroy)

  def create
    @practice    = @submission.practice
    @review      = @submission.reviews.build(review_params)
    @review.user = current_user
    if @review.save
      redirect_to @submission.practice, notice: t("review_was_successfully_created")
    else
      render "practices/show"
    end
  end

  def edit
  end

  def update
    if @review.update_attributes(review_params)
      redirect_back_or_to @review.submission.practice, notice: t("review_was_successfully_updated")
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to @review.submission.practice, notice: t("review_was_successfully_deleted")
  end

  private

    def review_params
      params.require(:review).permit(:message)
    end

    def set_submission
      @submission = Submission.find(params[:submission_id])
    end

    def set_review
      @review = Review.find(params[:id])
    end
end
