# frozen_string_literal: true

module UserDecorator
  def twitter_url
    "https://twitter.com/#{twitter_account}"
  end

  def role
    roles = [
      { role: :admin, value: admin },
      { role: :mentor, value: mentor },
      { role: :adviser, value: adviser },
      { role: :trainee, value: trainee },
      { role: :graduate, value: graduated_on },
      { role: :student, value: true }
    ]
    roles.detect { |v| v[:value] }[:role]
  end

  def staff_roles
    staff_roles = [
        { role: "管理者", value: admin },
        { role: "メンター", value: mentor },
        { role: "アドバイザー", value: adviser }
    ]
    staff_roles.find_all { |v| v[:value] }
        .map { |v| v[:role] }
        .join("、")
  end

  def icon_title
    [self.login_name, self.staff_roles].reject(&:blank?).join(": ")
  end

  def url
    user_url(self)
  end
end
