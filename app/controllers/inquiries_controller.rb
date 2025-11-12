# frozen_string_literal: true

class InquiriesController < ApplicationController
  include Recaptchable::V3
  skip_before_action :require_active_user_login, raise: false

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)
    result = valid_recaptcha?('inquiry')

    if result && @inquiry.save
      ActiveSupport::Notifications.instrument('came.inquiry', inquiry: @inquiry)
      InquiryMailer.incoming(@inquiry).deliver_later
      redirect_to new_inquiry_path, notice: 'お問い合わせを送信しました。'
    else
      flash.now[:alert] = 'Bot対策のため送信を拒否しました。しばらくしてからもう一度送信してください。' unless result
      render :new
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :body, :privacy_policy)
  end
end
