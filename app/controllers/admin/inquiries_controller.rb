# frozen_string_literal: true

class Admin::InquiriesController < AdminController
  def index
    @inquiries = Inquiry.all
  end

  def show
    @inquiry = Inquiry.find(params[:id])
  end
end
