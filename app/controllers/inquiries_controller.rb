# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :refuse_retired_login, raise: false
  skip_before_action :refuse_hibernated_login, raise: false

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)

    if @inquiry.save
      InquiryMailer.incoming(@inquiry).deliver_later
      redirect_to new_inquiry_url, notice: 'お問い合わせを送信しました。'
    else
      render :new
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :body, :privacy_policy)
  end
end
