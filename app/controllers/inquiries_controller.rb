# frozen_string_literal: true

class InquiriesController < ApplicationController
  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    if @inquiry.save
      InquiryMailer.incoming(@inquiry).deliver_now
      redirect_to new_inquiry_url, notice: "お問い合わせを送信しました。"
    else
      render :new
    end
  end

  private
    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :body)
    end
end
