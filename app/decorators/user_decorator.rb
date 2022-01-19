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
    classes << "is-#{role}"
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

  def format_to_channel
    {
      id: id,
      login_name: login_name,
      # 上記のurlメソッドをtimeline_channel.rbで使用した場合、user_urlでNomethoderrorが発生する。
      # user_urlが絶対パスを返す時、timeline_channel.rbがhostに関する情報を持たないことが原因だと考えられるが、channelにおけるhostの定義方法が分からず、以下のように記述した。
      path: Rails.application.routes.url_helpers.user_path(self),
      role: role,
      icon_title: icon_title,
      avatar_url: avatar_url
    }
  end
end
