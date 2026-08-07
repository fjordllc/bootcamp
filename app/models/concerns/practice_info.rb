# frozen_string_literal: true

module PracticeInfo
  extend ActiveSupport::Concern

  def elapsed_days
    if graduated_on.present?
      (graduated_on.to_date - created_at.to_date).to_i
    else
      (Date.current - created_at.to_date).to_i
    end
  end

  def training_remaining_days
    (training_ends_on - Time.zone.today).to_i
  end

  def grant_course?
    course = Course.find_by(id: course_id)
    course_id.present? && course&.grant?
  end
end
