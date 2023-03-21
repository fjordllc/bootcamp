# frozen_string_literal: true

module HomeHelper
  def today_or_tommorow(event)
    if event.holding_today?
      '今日'
    elsif event.holding_tomorrow?
      '明日'
    end
  end

  def anchor_to_required_field(attribute)
    {
      avatar_attached: 'form-user-avatar',
      tag_list_count: 'form-tag-list',
      after_graduation_hope: 'form-after-graduation-hope',
      discord_account: 'form-discord-account',
      github_account: 'form-github-account',
      blog_url: 'form-blog-url'
    }[attribute]
  end
end
