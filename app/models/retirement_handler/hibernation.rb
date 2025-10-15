# frozen_string_literal: true

class RetirementHandler::Hibernation
  def initialize(user)
    @user = user
  end

  def save_user(_params)
    reason = '（休会後三ヶ月経過したため自動退会）'
    @user.retire_reason = reason
    @user.save!(validate: false)
  end

  def notification_type
    :auto_retire
  end

  def notify_user
    true
  end

  def notify_admins_and_mentors
    true
  end

  def additional_clean_up; end
end
