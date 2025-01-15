# frozen_string_literal: true

class Admin::InquiriesController < AdminController
  PAGER_NUMBER = 20

  def index
    per = params[:per] || PAGER_NUMBER
    @inquiries = Inquiry.order(created_at: :desc).page(params[:page]).per(per)
  end

  def show
    @inquiry = Inquiry.find(params[:id])
    @comments = @inquiry.comments.order(created_at: :asc)
  end
end
