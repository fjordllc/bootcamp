# frozen_string_literal: true

class RetirementHandler::Admin
  def notification_type; end

  def notify_user
    false
  end

  def notify_admins_and_mentors
    false
  end

  def additional_clean_up; end
end
