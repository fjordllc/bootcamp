# frozen_string_literal: true

module UserDecorator
  NEW_USER_DAYS = 7

  include Role
  include Retire

  def twitter_url
    "https://twitter.com/#{twitter_account}"
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
    ActiveSupport::Duration.build(Time.zone.now - hibernated_at).in_days.floor if hibernated_at?
  end

  def other_editor_checked?(editors)
    editors.pop
    editor.present? && editors.exclude?(editor)
  end

  def editor_or_other_editor
    return nil if editor.nil?

    editor == 'other_editor' ? other_editor : t("activerecord.enums.user.editor.#{editor}")
  end

  def niconico_calendar(dates_and_reports)
    first_wday = dates_and_reports.first[:date].wday

    blanks = Array.new(first_wday) { { date: nil } }

    [*blanks, *dates_and_reports].each_slice(7).to_a
  end

  def joining_status
    elapsed_days <= NEW_USER_DAYS ? 'new-user' : ''
  end

  def user_icon_frame_class
    classes = ['a-user-role', "is-#{primary_role}"]
    classes << 'is-new-user' if joining_status == 'new-user'
    classes.join(' ')
  end
end
