# frozen_string_literal: true

class CorporateTrainingsController < ApplicationController
  include Recaptchable::V3
  skip_before_action :require_active_user_login, raise: false

  def new
    @corporate_training = CorporateTraining.new
  end

  def create
    @corporate_training = CorporateTraining.new(corporate_training_params)

    result = valid_recaptcha?('corporate_training')
    if result && @corporate_training.save
      CorporateTrainingMailer.incoming(@corporate_training).deliver_later
      redirect_to new_corporate_training_url, notice: 'お問い合わせを送信しました。'
    else
      flash.now[:alert] = 'Bot対策のため送信を拒否しました。しばらくしてからもう一度送信してください。' unless result
      render :new
    end
  end

  private

  def corporate_training_params
    params.require(:corporate_training).permit(
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
