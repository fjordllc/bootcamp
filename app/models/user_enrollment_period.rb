# frozen_string_literal: true

class UserEnrollmentPeriod
  def initialize(user)
    @user = user
  end

  def elapsed_days
    if @user.graduated_on.present?
      (@user.graduated_on.to_date - @user.created_at.to_date).to_i
    else
      (Date.current - @user.created_at.to_date).to_i
    end
  end

  def training_remaining_days
    (@user.training_ends_on - Time.zone.today).to_i
  end
end
