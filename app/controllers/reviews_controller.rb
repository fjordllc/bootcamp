class ReviewsController < ApplicationController
  before_action :set_submission, only: %i(create)
  before_action :set_review, only: %i(edit update destroy)

  def create
    @practice    = @submission.practice
    @review      = @submission.reviews.build(review_params)
    @review.user = current_user
    if @review.save
      flash[:notice] = t("review_was_successfully_created")
      redirect_back(fallback_location: @submission.practice)
    else
      render "practices/show"
    end
  end

  def edit
  end

  def update
    if @review.update_attributes(review_params)
      flash[:notice] = t("review_was_successfully_updated")
      redirect_back(fallback_location: @review.submission.practice)
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    flash[:notice] = t("review_was_successfully_deleted")
    redirect_back(fallback_location: @review.submission.practice)
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
