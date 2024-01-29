# frozen_string_literal: true

module UserDecorator
  def twitter_url
    "https://twitter.com/#{twitter_account}"
  end

  def roles
    role_list = [
      { role: 'retired', value: retired? },
      { role: 'hibernationed', value: hibernated? },
      { role: 'admin', value: admin? },
      { role: 'mentor', value: mentor? },
      { role: 'adviser', value: adviser? },
      { role: 'graduate', value: graduated? },
      { role: 'trainee', value: trainee? }
    ]
    roles = role_list.find_all { |v| v[:value] }
                     .map { |v| v[:role] }
    roles << :student if roles.empty?

    roles
  end

  def primary_role
    roles.first
  end

  def staff_roles
    staff_roles = [
      { role: '管理者', value: admin? },
      { role: 'メンター', value: mentor? },
      { role: 'アドバイザー', value: adviser? }
    ]
    staff_roles.find_all { |v| v[:value] }
               .map { |v| v[:role] }
               .join('、')
  end

  def roles_to_s
    return '' if roles.empty?

    roles = [
      { role: '退会ユーザー', value: retired? },
      { role: '休会ユーザー', value: hibernated? },
      { role: '管理者', value: admin? },
      { role: 'メンター', value: mentor? },
      { role: 'アドバイザー', value: adviser? },
      { role: '卒業生', value: graduated? },
      { role: '研修生', value: trainee? }
    ]
    roles.find_all { |v| v[:value] }
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
    "#{login_name} (#{name_kana})"
  end

  def private_name
    "#{name} (#{name_kana})"
  end

  def enrollment_period
    if graduated?
      if elapsed_days.positive?
        tag.span(" (#{l graduated_on}卒業 #{elapsed_days}日) ") + tag.a("#{generation}期生", href: generation_path(generation))
      else
        tag.span(" (#{l graduated_on}卒業 ") + tag.a("#{generation}期生", href: generation_path(generation))
      end
    else
      tag.span(" #{elapsed_days}日目 ") + tag.a("#{generation}期生", href: generation_path(generation))
    end
  end

  def subdivisions_of_country
    return if country_code.blank?

    country = ISO3166::Country[country_code]
    country.subdivision_names_with_codes(I18n.locale.to_s)
  end

  def address
    if country_code.present? && subdivision_code.present?
      "#{subdivision_name} (#{country_name})"
    elsif country_code.present? && subdivision_code.blank?
      country_name
    end
  end

  def hibernation_days
    return unless hibernated_at

    ActiveSupport::Duration.build(Time.zone.now - hibernated_at).in_days.floor
  end

  def retire_countdown
    return unless hibernated_at

    ActiveSupport::Duration.build(scheduled_retire_at - Time.zone.now)
  end

  def retire_deadline
    countdown =
      if retire_countdown.in_hours < 1
        "#{retire_countdown.in_minutes.floor}分"
      elsif retire_countdown.in_hours < 24
        "#{retire_countdown.in_hours.floor}時間"
      else
        "#{retire_countdown.in_days.floor}日"
      end

    "#{l scheduled_retire_at} (自動退会まであと#{countdown})"
  end
end
