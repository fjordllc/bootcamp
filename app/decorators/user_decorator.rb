# frozen_string_literal: true

module UserDecorator
  def twitter_url
    "https://twitter.com/#{twitter_account}"
  end

  def roles
    roles = []

    roles << :admin if admin?
    roles << :mentor if mentor?
    roles << :adviser if adviser?
    roles << :trainee if trainee?
    roles << :graduate if graduated_on?
    roles << :student if roles.empty?

    roles
  end

  def primary_role
    roles.first
  end

  def staff_roles
    staff_roles = [
      { role: '管理者', value: admin },
      { role: 'メンター', value: mentor },
      { role: 'アドバイザー', value: adviser }
    ]
    staff_roles.find_all { |v| v[:value] }
               .map { |v| v[:role] }
               .join('、')
  end

  def icon_title
    ["#{login_name} (#{name})", staff_roles].reject(&:blank?)
                                            .join(': ')
  end

  def url
    user_url(self)
  end

  def icon_classes(*classes)
    classes << 'a-user-icon'
    classes << "is-#{primary_role}"
    classes << 'is-daimyo' if daimyo?
    classes.join(' ')
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

  def title
    login_name
  end

  def long_name
    "#{login_name} (#{name})"
  end
end
