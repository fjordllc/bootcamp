# frozen_string_literal: true

class Admin::InquiriesController < AdminController
  def index
    @inquiries = Inquiry.order(created_at: :desc)
  end

  def show
    @inquiry = Inquiry.find(params[:id])
  end
end
