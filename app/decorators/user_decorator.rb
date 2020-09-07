# frozen_string_literal: true

module UserDecorator
  DAYS_IN_WEEK = 7
  CALENDAR_TERM = 30

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
    [self.login_name, self.staff_roles].reject(&:blank?)
                                       .join(": ")
  end

  def url
    user_url(self)
  end

  def niconico_calendar
    reports_date_and_emotion = self.reports_date_and_emotion(CALENDAR_TERM)
    last_wday = reports_date_and_emotion.first[:date].wday

    blanks = last_wday.times.map { { report: nil, date: nil, emotion: nil } }

    [ *blanks, *reports_date_and_emotion].each_slice(DAYS_IN_WEEK)
                                         .to_a
  end

  def icon_classes(*classes)
    classes << "a-user-icon"
    classes << "is-#{role}"
    classes << "is-daimyo" if daimyo?
    classes.join(" ")
  end

  def cached_completed_percentage
    Rails.cache.fetch "/model/user/#{id}/completed_percentage" do
      completed_percentage
    end
  end

  def customer_url
    "https://dashboard.stripe.com/customers/#{customer_id}"
  end

  def subscription_url
    "https://dashboard.stripe.com/subscriptions/#{subscription_id}"
  end
end
