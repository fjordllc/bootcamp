# frozen_string_literal: true

class Admin::CorporateTrainingInquiriesController < AdminController
  PAGER_NUMBER = 20
  def index
    per = params[:per] || PAGER_NUMBER
    @corporate_training_inquiries = CorporateTrainingInquiry.order(created_at: :desc).page(params[:page]).per(per)
  end

  def show
    @corporate_training_inquiry = CorporateTrainingInquiry.find(params[:id])
    @comments = @corporate_training_inquiry.comments.order(:created_at)
  end
end
