class AbsenceDays
  def calculate_absence_days(user)
    return unless user.hibernated_at

    ((Time.zone.now - user.hibernated_at) / 86_400).floor
  end
end