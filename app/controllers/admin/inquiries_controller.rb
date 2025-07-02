# frozen_string_literal: true

class Admin::InquiriesController < AdminController
  PAGER_NUMBER = 20

  def index
    per = params[:per] || PAGER_NUMBER
    @inquiries = Inquiry.includes(checks: :user).order(created_at: :desc, id: :desc).page(params[:page]).per(per)
  end

  def show
    @inquiry = Inquiry.find(params[:id])
    @comments = @inquiry.comments.order(:created_at)
  end
end
