# frozen_string_literal: true

class CorporateTrainingInquiriesController < ApplicationController
  include Recaptchable::V3
  skip_before_action :require_active_user_login, raise: false

  def new
    @corporate_training_inquiry = CorporateTrainingInquiry.new
  end

  def create
    @corporate_training_inquiry = CorporateTrainingInquiry.new(corporate_training_inquiry_params)

    result = valid_recaptcha?('inquiry')
    if result && @corporate_training_inquiry.save
      CorporateTrainingInquiryMailer.incoming(@corporate_training_inquiry).deliver_later
      render :complete
    else
      flash.now[:alert] = 'Bot対策のため送信を拒否しました。しばらくしてからもう一度送信してください。' unless result
      render :new
    end
  end

  private

  def corporate_training_inquiry_params
    params.require(:corporate_training_inquiry).permit(
      :company_name,
      :name,
      :email,
      :meeting_date1,
      :meeting_date2,
      :meeting_date3,
      :participants_count,
      :training_duration,
      :how_did_you_hear,
      :additional_information,
      :privacy_policy
    )
  end
end
